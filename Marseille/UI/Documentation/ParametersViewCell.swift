//
//  ParametersViewCell.swift
//  Marseille
//
//  Created by Serena on 19/04/2023.
//  

import UIKit

class ParametersViewCell: UICollectionViewCell {
	let nameLabel = UILabel()
	let descriptionLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		nameLabel.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(nameLabel)
		
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(descriptionLabel)
		
		NSLayoutConstraint.activate([
			nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 10),
			nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			
			descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
        
//        descriptionLabel.numberOfLines = 0
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup(with params: Parameters, context: [String: Reference]) {
		nameLabel.text = params.name
        descriptionLabel.attributedText = params.content.combiningAttributedStrings(with: context)
	}
	
}
