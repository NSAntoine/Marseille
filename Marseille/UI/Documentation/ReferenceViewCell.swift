//
//  ReferenceViewCell.swift
//  Marseille
//
//  Created by Serena on 07/04/2023.
//  

import UIKit

class ReferenceViewCell: UICollectionViewCell {
    static let secondaryTextFont: UIFont = .italicSystemFont(ofSize: UIFont.smallSystemFontSize)
    
	func setup(with ref: Reference) {
		var conf = UIListContentConfiguration.cell()
		if let fragments = ref.fragments {
			conf.attributedText = fragments.combiningAttributedStrings(with: SyntaxToken.Context(isMakingAttributedStringForList: true))
		} else {
			conf.text = ref.title
			conf.textProperties.font = .preferredFont(forTextStyle: .title3)
			conf.textProperties.color = .link
		}
		
		conf.secondaryText = (ref.abstract ?? []).compactMap(\.text).joined()
		conf.secondaryTextProperties.color = .secondaryLabel
        conf.secondaryTextProperties.font = Self.secondaryTextFont
		contentConfiguration = conf
	}
}
