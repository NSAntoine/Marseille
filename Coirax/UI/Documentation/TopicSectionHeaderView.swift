//
//  TopicSectionHeaderView.swift
//  Coirax
//
//  Created by Serena on 07/04/2023.
//  

import UIKit

class TopicSectionHeaderView: UICollectionReusableView {
	let nameLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		nameLabel.font = .boldSystemFont(ofSize: 28)
//		nameLabel.numberOfLines = 0
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.adjustsFontForContentSizeCategory = true
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(nameLabel)
		
		NSLayoutConstraint.activate([
			nameLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
			nameLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		nameLabel.text = nil
	}
}
