//
//  PlatformViewCell.swift
//  Marseille
//
//  Created by Serena on 06/04/2023.
//  

import UIKit

class PlatformViewCell: UICollectionViewCell {
//
//	let platformImageView = UIImageView()
//	let nameLabel = UILabel()
//
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .quaternarySystemFill
		layer.cornerRadius = 10
		layer.cornerCurve = .continuous
		
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 1
		layer.shadowOffset = .zero
		layer.shadowRadius = 10
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup(with platform: Platform) {
		var conf = UIListContentConfiguration.cell()
		conf.textProperties.adjustsFontSizeToFitWidth = true
		if let deprecatedAt = platform.deprecatedAt {
			conf.text = "\(platform.name) \(platform.introducedAt)-\(deprecatedAt)"
            conf.secondaryText = "DEPRECATED."
            conf.secondaryTextProperties.font = .italicSystemFont(ofSize: 8)
            conf.secondaryTextProperties.color = .secondaryLabel
            
			layer.borderColor = UIColor.systemOrange.cgColor
			layer.borderWidth = 1.0
		} else {
			conf.text = "\(platform.name) \(platform.introducedAt)+"
		}
		
		conf.textProperties.font = .preferredFont(forTextStyle: .footnote)
		conf.image = platform.image
		contentConfiguration = conf
	}
	
}
