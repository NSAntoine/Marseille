//
//  TechnologyViewCell.swift
//  Coirax
//
//  Created by Serena on 04/01/2023
//
	

import UIKit

/// a UICollectionViewCell subclass of an individual
class TechnologyViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TechnologyViewCell"
    static let titleFont: UIFont = .preferredFont(forTextStyle: .title2)
    static let descriptionFont: UIFont = .preferredFont(forTextStyle: .subheadline)
    
    static let italicDescriptionFont = {
        let desc = descriptionFont.fontDescriptor.withSymbolicTraits(.traitItalic)!
        return UIFont(descriptor: desc, size: descriptionFont.pointSize)
    }()
    
    static let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
    
    static let cellBackgroundColor = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .tertiarySystemBackground
        default:
            return .systemBackground
        }
    }
    
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var tech: DisplayTechnology?
    
    func setup() {
        guard let tech else { return }
        titleLabel = UILabel()
        titleLabel.textColor = tintColor
        titleLabel.font = Self.titleFont
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = tech.tech.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        ])
        
        /*
         https://developer.apple.com/documentation/technologies?changes=latest_major
         https://developer.apple.com/documentation/technologies?changes=latest_minor
         https://developer.apple.com/documentation/technologies?changes=latest_beta
         */
        
        layer.cornerCurve = .circular
        layer.cornerRadius = 14
        backgroundColor = Self.cellBackgroundColor
        
        descriptionLabel = UILabel()
        if let abstractText = tech.reference.abstract?.compactMap(\.text).joined() {
            descriptionLabel.text = abstractText
            descriptionLabel.font = Self.descriptionFont
        } else {
            descriptionLabel.text = "No description provided"
            descriptionLabel.font = Self.italicDescriptionFont
        }
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .secondaryLabel
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        /*
        let imageView = UIImageView(image: Self.chevronImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor)
        ])
         */
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
    
    override var reuseIdentifier: String? {
        Self.reuseIdentifier
    }
    
    override var isUserInteractionEnabled: Bool {
        get {
            super.isUserInteractionEnabled
        }
        
        set {
            super.isUserInteractionEnabled = newValue
            titleLabel.isEnabled = newValue
            descriptionLabel?.isEnabled = newValue
        }
    }
}
