//
//  TechnologiesListViewController.swift
//  Coirax
//
//  Created by Serena on 03/01/2023
//


import UIKit
import class SwiftUI.UIHostingController
import UIKitPrivates

class TechnologiesListViewController: UIViewController {
    // the main collection view
    var collectionView: UICollectionView!
    var dataSource: DataSource!
    
    var searchWorkItem: DispatchWorkItem?
    var allItems: [DisplayTechnology] = []
    
    var sectionNames: [String] = []
    var selectedSections: Set<String> = []
    
    /// You may ask, why is this stored here?
    /// Well, when pushing to another view controller with `navigationController.pushViewController(_:, animated:)`
    /// if `navigationItem._bottomPalette` is present, a graphical glitch will occur,
    /// So we nil `navigationItem._bottomPalette` when pushing,
    /// then set it back when the view appears.
    private var _storedPalette: _UINavigationBarPalette?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Technologies"
        navigationController?.navigationBar.prefersLargeTitles = true
        // until we get the data, disable the search bar
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        setupCollectionView()
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // see the comments on _storedPalette.
        navigationItem._bottomPalette = _storedPalette
    }
}

extension TechnologiesListViewController: UICollectionViewDelegate {
    // MARK: - Collection view & data source setup
    enum Section {
        case main
    }
    
    @available(iOS 14.0, *)
    typealias CellRegistration = UICollectionView.CellRegistration<TechnologyViewCell, DisplayTechnology>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, DisplayTechnology>
    
    func setupCollectionView() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.delegate = self
        
        dataSource = makeDataSource()
        collectionView.dataSource = dataSource
        
        if #unavailable(iOS 14) {
            collectionView.register(TechnologyViewCell.self,
                                    forCellWithReuseIdentifier: TechnologyViewCell.reuseIdentifier)
        }
        
        view.addSubview(collectionView)

		collectionView.constraintCompletely(to: view)
    }
    
    func makeDataSource() -> DataSource {
        if #available(iOS 14, *) {
            let cellRegistration = CellRegistration { cell, indexPath, itemIdentifier in
                cell.tech = itemIdentifier
                cell.setup()
            }

            return DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TechnologyViewCell.reuseIdentifier,
                                                          for: indexPath) as! TechnologyViewCell
            cell.tech = itemIdentifier
            cell.setup()
            return cell
        }
    }
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(94))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 10, trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath), let url = item.reference.url else {
            collectionView.cellForItem(at: indexPath)?.isUserInteractionEnabled = false
            return
        }
        
        print(item.reference.type, url)
        
        switch item.reference.type {
        case .topic:
            // when the reference type is a `topic`, the url property isn't the full URL
            // but actually just the path of the item,
            // ie, `/documentation/classkit`
            // so we must append the 'url' property to 'URL.documentationBaseURL'
            // then append '.json' as the extension to get the json
            print("here")
            let topicJSONURL: URL = URL.documentationBaseURL.appending(url.appending(".json")).constructDocumentationURL(forLanguage: Preferences.interfaceLanguage)
            tryGoToTopic(withURL: topicJSONURL)
            
        case .link:
            UIApplication.shared.open(URL(string: url)!)
        default:
            break // not supposed to be here anyways..
        }
    }
    
    func tryGoToTopic(withURL url: URL) {
        navigationItem._bottomPalette = nil
        
		if let cached = Network.shared.networkCache.object(forKey: url as NSURL) {
			let vc = DocumentationViewController(documentation: cached.value)
			navigationController?.pushViewController(vc, animated: true)
			return
		}
		
		let alert = UIAlertController(title: "Loading...", message: nil, preferredStyle: .alert)
		present(alert, animated: true)
		
        let task = Task {
            do {
                let documentation = try await Network.shared.topicDocumentation(for: url) { status in
                    DispatchQueue.main.async {
                        alert.message = "\(status)"
                    }
                }
				alert.dismiss(animated: false) { [unowned self] in
					let vc = DocumentationViewController(documentation: documentation)
					navigationController?.pushViewController(vc, animated: true)
				}
            } catch {
				alert.dismiss(animated: true) { [unowned self] in
					errorAlert(title: "Error while trying to fetch information for topic (URL: \(url))",
							   message: error.localizedDescription)
					print(error)
					navigationItem._bottomPalette = _storedPalette
				}
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
            task.cancel()
        })
        
    }
}

extension TechnologiesListViewController {
    // MARK: - Data fetching and stuff
    func fetchData() {
        Task(priority: .high) {
            let spinner = _addLoadingSpinner()
            
            do {
                let tech = try await Network.shared.request(to: Technologies.fetchURL, returning: Technologies.self)
                update(to: tech)
            } catch {
                let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                    self.fetchData()
                }
				print(error)
                errorAlert(title: "Error trying to get technologies", message: error.localizedDescription, actions: [retryAction])
            }
            
            (spinner.arrangedSubviews[0] as? UIActivityIndicatorView)?.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
    
    /// Adds a spinner + a loading label in the form of a UIStackView
    /// and then returns the stack view so that the reciver can manage it
    private func _addLoadingSpinner() -> UIStackView {
        let indicator = UIActivityIndicatorView(style: .large)
        let loadingLabel = UILabel()
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .lightGray
        indicator.startAnimating()
        
        let stackView = UIStackView(arrangedSubviews: [indicator, loadingLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        collectionView.addSubview(stackView)
        
        stackView.centerConstraints(to: collectionView)
        
        return stackView
    }
    
    func setItems(_ items: [DisplayTechnology]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DisplayTechnology>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
    
    /// Updates the current items & section names to the given `Technologies` instance
    func update(to tech: Technologies) {
        for section in tech.sections {
            if let technologies = section.groups?.flatMap(\.technologies) {
                allItems = technologies.compactMap { item in
                    if let id = item.destination.identifier {
                        return DisplayTechnology(tech: item, reference: tech.references[id]!)
                    }
                    return nil
                }

                if let groups = section.groups {
                    sectionNames += groups.map(\.name)
                }
                
                setItems(allItems)
            }
        }
        
        let sectionButtons = sectionNames.enumerated().map { (index, section) in
            let button: UIButton
            
            if #available(iOS 15.0, *) {
                button = UIButton(configuration: .bordered())
            } else {
                button = UIButton(type: .system)
                button.backgroundColor = .systemFill
                button.layer.cornerRadius = 5.949999999999999
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                button.titleLabel?.lineBreakMode = .byClipping
            }
            
            button.tag = index
            button.addTarget(self,
                             action: #selector(handleSectionButtonClicked),
                             for: .touchUpInside)
            button.setTitle(section, for: .normal)
            return button
        }
//        
        let sectionStackView = UIStackView(arrangedSubviews: sectionButtons)
        sectionStackView.translatesAutoresizingMaskIntoConstraints = false
        sectionStackView.spacing = 10
        addViewToPalette(sectionStackView)
		
//		let sectionsView = TechnologiesSectionsView(sectionNames: sectionNames, sectionChangeHandler: handleSectionButtonClicked)
//		
//		let vc = UIHostingController(rootView: sectionsView)
//		vc.view.backgroundColor = .clear
//		let view = vc.view!
//		view.translatesAutoresizingMaskIntoConstraints = false
//
//		addViewToPalette(view)
    }
    
    @objc
	func handleSectionButtonClicked(sender: UIButton) {
        let section = sectionNames[sender.tag]
        let isSectionAlreadySelected = selectedSections.contains(section)
        
        if isSectionAlreadySelected {
            selectedSections.remove(section)
        } else {
            selectedSections.insert(section)
        }
        
        // set the button appearance to reflect the changes
        if #available(iOS 15.0, *) {
            sender.configuration = isSectionAlreadySelected ? .bordered() : .borderedProminent()
        } else {
            sender.backgroundColor = isSectionAlreadySelected ? .systemFill : .borderedButtonColor
        }
        
        let items = allItems.filter { item in
            return selectedSections.isSubset(of: item.tech.tags)
        }
        
        setItems(items)
    }
    
    func addViewToPalette(_ viewToAdd: UIView) {
        let contentView = UIScrollView(size: CGSize(width: view.bounds.width, height: navigationController!.navigationBar.bounds.height - 100))
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewToAdd)
        
        NSLayoutConstraint.activate([
            viewToAdd.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor/*, constant: 8*/),
            contentView.trailingAnchor.constraint(equalTo: viewToAdd.layoutMarginsGuide.trailingAnchor/*, constant: 8*/),
            viewToAdd.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: viewToAdd.bottomAnchor)
        ])
        
        
        let palette = _UINavigationBarPalette(contentView: contentView)
        palette.constraintCompletely(to: contentView)
        palette.translatesAutoresizingMaskIntoConstraints = false

        _storedPalette = palette
        navigationItem._bottomPalette = palette
    }
}

extension TechnologiesListViewController: UISearchBarDelegate {
    // MARK: - Search stuff
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            setItems(allItems) // search text is empty, show all items
            return
        }
        
        searchWorkItem?.cancel()
        
        let newWorkItem = DispatchWorkItem { [self] in
            let newItems = allItems.filter { tech in
                tech.tech.title.localizedCaseInsensitiveContains(searchText) && selectedSections.isSubset(of: tech.tech.tags)
            }
            
            setItems(newItems)
        }
        
        searchWorkItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: newWorkItem)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        setItems(allItems)
    }
}

