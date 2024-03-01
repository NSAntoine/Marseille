//
//  DocumentationInfoHeaderCell.swift
//  Marseille
//
//  Created by Serena on 06/04/2023.
//  

import UIKit

class DocumentationInfoHeaderCell: UICollectionViewCell {
	let roleHeadingLabel = UILabel(text: nil, font: .italicSystemFont(ofSize: UIFont.smallSystemFontSize), textColor: .secondaryLabel)
	let titleLabel = UILabel(text: nil, font: .systemFont(ofSize: 30, weight: .regular))
	let subtitleLabel = UILabel(text: nil,
								font: .italicSystemFont(ofSize: 15),
								textColor: .secondaryLabel)
	let separatorView: UIView = .init()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		titleLabel.numberOfLines = 0
		roleHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		subtitleLabel.numberOfLines = 0
		
		separatorView.backgroundColor = .separator
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(roleHeadingLabel)
		contentView.addSubview(titleLabel)
		contentView.addSubview(subtitleLabel)
		contentView.addSubview(separatorView)
		
		NSLayoutConstraint.activate([
            roleHeadingLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 7),
			roleHeadingLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			
			titleLabel.leadingAnchor.constraint(equalTo: roleHeadingLabel.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: roleHeadingLabel.bottomAnchor),
			
			subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
			subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			
//			separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 5),
			separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup(with doc: TopicDocumentation) {
		roleHeadingLabel.text = doc.metadata.roleHeading
		titleLabel.text = doc.metadata.title
		subtitleLabel.text = (doc.abstract ?? []).compactMap(\.text).joined()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		roleHeadingLabel.text = nil
		titleLabel.text = nil
		subtitleLabel.text = nil
	}
}
