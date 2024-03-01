//
//  DocumentationViewController.swift
//  Coirax
//
//  Created by Serena on 06/04/2023.
//  

import UIKit

struct DeclCellConfiguration: Hashable {
    let decl: Declaration
    let includePlatformNames: Bool
}

class DocumentationViewController: UIViewController {
	
	enum Item: Hashable {
		case headerInformation
		case platform(Platform)
        case declaration(DeclCellConfiguration)
		case parameter(Parameters)
		case reference(Reference)
	}
	
	enum Section: Hashable {
		case headerInformation
		case platforms
        case declarations
		case parameters
		case topicSection(title: String)
	}
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
	
	typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
	var dataSource: DataSource!
	
	var collectionView: UICollectionView!
	
	var documentation: TopicDocumentation
	
	init(documentation: TopicDocumentation) {
		self.documentation = documentation
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .never
        
//        dump(self.documentation)
        
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
		collectionView.backgroundColor = .secondarySystemBackground
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)
		collectionView.constraintCompletely(to: view)
		
		let headerInfoCellRegistration = UICollectionView.CellRegistration<DocumentationInfoHeaderCell, TopicDocumentation> { cell, indexPath, doc in
			cell.setup(with: doc)
		}
		
		let platformCellRegistration = UICollectionView.CellRegistration<PlatformViewCell, Platform> { cell, indexPath, doc in
			cell.setup(with: doc)
		}
		
		let referenceCellRegistration = UICollectionView.CellRegistration<ReferenceViewCell, Reference> { cell, indexPath, ref in
			cell.setup(with: ref)
		}
		
        let paramCtx: [String: Reference] = self.documentation.references
		let parametersCellRegistration = UICollectionView.CellRegistration<ParametersViewCell, Parameters> { cell, indexPath, param in
            cell.setup(with: param, context: paramCtx)
		}
        
        let declsCellRegistration = UICollectionView.CellRegistration<DeclarationCell, DeclCellConfiguration> { cell, indexPath, configuration in
            cell.setup(withConfiguration: configuration, refs: self.documentation.references)
            cell.openURLFunction = self.handleDocumentationURLTap(_:)
        }
		
		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
			switch item {
			case .headerInformation:
				return collectionView.dequeueConfiguredReusableCell(using: headerInfoCellRegistration,
																	for: indexPath, item: self.documentation)
			case .platform(let platform):
				return collectionView.dequeueConfiguredReusableCell(using: platformCellRegistration, for: indexPath, item: platform)
			case .reference(let ref):
				return collectionView.dequeueConfiguredReusableCell(using: referenceCellRegistration, for: indexPath, item: ref)
            case .declaration(let decl):
                return collectionView.dequeueConfiguredReusableCell(using: declsCellRegistration, for: indexPath, item: decl)
			case .parameter(let param):
				return collectionView.dequeueConfiguredReusableCell(using: parametersCellRegistration, for: indexPath, item: param)
			}
		}
		
		let headerSupplementary = UICollectionView.SupplementaryRegistration<TopicSectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
			switch dataSource.snapshot().sectionIdentifiers[indexPath.section] {
			case .topicSection(let title):
				supplementaryView.nameLabel.text = title
			case .parameters:
				supplementaryView.nameLabel.text = "Parameters"
			default:
//				fatalError("Sorry, we don't do headers around here")
				break
			}
		}
		
		dataSource.supplementaryViewProvider = {  collectionView, kind, indexPath in
			return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementary, for: indexPath)
		}
		collectionView.dataSource = dataSource
		collectionView.delegate = self
		
		let snapshot = createSnapshot(fromDocs: documentation)
		
		dataSource.apply(snapshot)
        
        navigationItem.rightBarButtonItem = makeBarButtonItem()
	}
    
    func updateWith(_ newDocumentation: TopicDocumentation) {
        DispatchQueue.main.async {
            self.documentation = newDocumentation
            self.dataSource.apply(self.createSnapshot(fromDocs: newDocumentation))
            self.navigationItem.rightBarButtonItem = self.makeBarButtonItem()
        }
    }
    
    func makeBarButtonItem() -> UIBarButtonItem {
        let selectedLanguage = documentation.identifier.interfaceLanguage
        let varaintsMenuActions = documentation.variants.compactMap { variant in
            guard !variant.paths.isEmpty, !variant.traits.isEmpty else { return nil }
            let _language = variant.traits[0].interfaceLanguage
            let language = InterfaceLanguage(rawValue: _language)!
            
            return UIAction(title: language.displayName, state: language.rawValue == selectedLanguage ? .on : .off) { _ in
                Preferences.interfaceLanguage = language
                let path = variant.paths[0].appending(".json")
                let url = URL.documentationBaseURL.appending(path).constructDocumentationURL(forLanguage: language)
                
                Task {
                    let newDocumentation = try await Network.shared.topicDocumentation(for: url)
                    self.updateWith(newDocumentation)
                }
            }
        } as [UIAction]
        
        return UIBarButtonItem(title: InterfaceLanguage(rawValue: selectedLanguage)?.displayName ?? selectedLanguage, menu: UIMenu(children: varaintsMenuActions))
    }
    
    deinit {
        print("DocumentationViewController deallocated")
    }
    
    func createSnapshot(fromDocs documentation: TopicDocumentation) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.headerInformation])
        snapshot.appendItems([.headerInformation], toSection: .headerInformation)
        
        if let platforms = documentation.metadata.platforms, !platforms.isEmpty {
            snapshot.appendSections([.platforms])
            snapshot.appendItems(platforms.map { Item.platform($0) }, toSection: .platforms)
        }
        
        for topicSection in documentation.topicSections ?? [] {
            let section: Section = .topicSection(title: topicSection.title)
            snapshot.appendSections(
                [section]
            )
            
            let references = topicSection.identifiers.map { id in
                let ref = documentation.references[id]!
                return Item.reference(ref)
            }
            
            snapshot.appendItems(references, toSection: section)
        }
        
        for section in documentation.primaryContentSections ?? [] {
            switch section.value {
            case .declarations(let decls):
                if !snapshot.sectionIdentifiers.contains(.declarations) {
                    snapshot.insertSections([.declarations], afterSection: .headerInformation)
                }
                
                let includeParamName = decls.count > 1
                let declCellConfs = decls.map { declaration in
                    Item.declaration(DeclCellConfiguration(decl: declaration, includePlatformNames: includeParamName))
                }
                
                snapshot.appendItems(declCellConfs, toSection: .declarations)
                print("Added decls to snapshot")
            case .parameters(let params):
                if !snapshot.sectionIdentifiers.contains(.parameters) {
                    snapshot.appendSections([.parameters])
                }
                snapshot.appendItems(params.map { Item.parameter($0) })
            default:
                break
            }
        }
        
        return snapshot
    }
    
    
    func pushWithCompleteURL(_ urlToPushTo: URL) {
        if let cached = Network.shared.networkCache.object(forKey: urlToPushTo as NSURL) {
            navigationController?.pushViewController(DocumentationViewController(documentation: cached.value), animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Loading...", message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        
        let task = Task {
            do {
                let documentation = try await Network.shared.topicDocumentation(for: urlToPushTo) { status in
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
                    errorAlert(title: "Error while trying to fetch information for topic (URL: \(urlToPushTo))",
                               message: error.localizedDescription)
                    print(error)
                }
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
            task.cancel()
        })
    }
    
    func handleDocumentationURLTap(_ url: String) {
        let urlToPushTo = URL.documentationBaseURL.appending(url.appending(".json")).constructDocumentationURL(forLanguage: .init(rawValue: documentation.identifier.interfaceLanguage) ?? Preferences.interfaceLanguage)
        pushWithCompleteURL(urlToPushTo)
    }
    
    func handleReferenceTap(_ ref: Reference) {
        guard let url = ref.url else {
            return
        }
        
        handleDocumentationURLTap(url)
    }
}

extension DocumentationViewController: UICollectionViewDelegate {
	// MARK: UICollectionViewDelegate & other UICollectionView stuff
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		switch dataSource.itemIdentifier(for: indexPath) {
		case .reference(_):
			return true
		default:
			return false
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch dataSource.itemIdentifier(for: indexPath) {
		case .reference(let ref):
            handleReferenceTap(ref)
		default:
			return
		}
	}
}

extension DocumentationViewController {
	// MARK: - Layout
	func makeLayout() -> UICollectionViewLayout {
		var sections: [Section] {
			dataSource.snapshot().sectionIdentifiers
		}
		
		return UICollectionViewCompositionalLayout { section, env in
			switch sections[section] {
			case .headerInformation:
				let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
													  heightDimension: .estimated(120))
				let item = NSCollectionLayoutItem(layoutSize: itemSize)
				let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(120))
				
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
				let section = NSCollectionLayoutSection(group: group)
//				section.contentInsets.bottom = 10
				return section
			case .platforms:
				let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
													  heightDimension: .fractionalHeight(1.0))
				
				let item = NSCollectionLayoutItem(layoutSize: itemSize)
				
				let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
													   heightDimension: .absolute(50))

				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
				let spacing = CGFloat(10)
				group.interItemSpacing = .fixed(spacing)
				
				let section = NSCollectionLayoutSection(group: group)
				section.interGroupSpacing = spacing
//				section.orthogonalScrollingBehavior = .continuous
				section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
				return section
            case .declarations:
                var listConf = UICollectionLayoutListConfiguration(appearance: .plain)
                listConf.backgroundColor = .clear
                listConf.showsSeparators = false
                let section = NSCollectionLayoutSection.list(using: listConf, layoutEnvironment: env)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
                section.interGroupSpacing = 10
                return section
			case .topicSection(_):
				var listConf = UICollectionLayoutListConfiguration(appearance: .plain)
				listConf.backgroundColor = .clear
				listConf.showsSeparators = false
				let section: NSCollectionLayoutSection = .list(using: listConf, layoutEnvironment: env)
				
				let titleHeaderSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(55)
				)
				
				let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: titleHeaderSize,
					elementKind: UICollectionView.elementKindSectionHeader,
					alignment: /*layoutMode == .horizantal ? .top : .topLeading*/.topLeading
				)
				
				section.boundarySupplementaryItems = [
					titleSupplementary
				]
				
				return section
			case .parameters:
				var listConf = UICollectionLayoutListConfiguration(appearance: .plain)
				listConf.backgroundColor = .clear
				listConf.showsSeparators = false
				
				let section: NSCollectionLayoutSection = .list(using: listConf, layoutEnvironment: env)
				
				let titleHeaderSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(55)
				)
				
				let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: titleHeaderSize,
					elementKind: UICollectionView.elementKindSectionHeader,
					alignment: /*layoutMode == .horizantal ? .top : .topLeading*/.topLeading
				)
				
				section.boundarySupplementaryItems = [titleSupplementary]
				
				return section
			}
		}
	}
}
