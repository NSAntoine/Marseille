//
//  DeclarationCell.swift
//  Coirax
//
//  Created by Serena on 29/02/2024.
//  

import UIKit

class DeclarationCell: UICollectionViewCell {
    
    var platformsLabel: UILabel!
    var declBoxSubview: UIView!
    var declBoxLabel: UITextView!
    var openURLFunction: ((String) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        platformsLabel = UILabel()
        platformsLabel.translatesAutoresizingMaskIntoConstraints = false
        platformsLabel.font = .italicSystemFont(ofSize: 13)
        contentView.addSubview(platformsLabel)
        
        NSLayoutConstraint.activate([
            platformsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            platformsLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        declBoxSubview = UIView()
        declBoxSubview.translatesAutoresizingMaskIntoConstraints = false
        declBoxSubview.backgroundColor = .secondarySystemFill
        declBoxSubview.layer.cornerRadius = 10
        contentView.addSubview(declBoxSubview)
        
        NSLayoutConstraint.activate([
            declBoxSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            declBoxSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            declBoxSubview.topAnchor.constraint(equalTo: platformsLabel.bottomAnchor, constant: 5),
            declBoxSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        declBoxSubview.layer.shadowColor = UIColor.black.cgColor
        declBoxSubview.layer.shadowRadius = 10
        
        declBoxLabel = UITextView()
        declBoxLabel.isScrollEnabled = false
        declBoxLabel.backgroundColor = .clear
        declBoxLabel.isEditable = false
        declBoxLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(declBoxLabel)
        
        NSLayoutConstraint.activate([
            declBoxLabel.leadingAnchor.constraint(equalTo: declBoxSubview.leadingAnchor, constant: 10),
            declBoxLabel.trailingAnchor.constraint(equalTo: declBoxSubview.trailingAnchor, constant: -10),
            declBoxLabel.centerYAnchor.constraint(equalTo: declBoxSubview.centerYAnchor),
            declBoxLabel.topAnchor.constraint(equalTo: declBoxSubview.topAnchor),
            declBoxLabel.bottomAnchor.constraint(equalTo: declBoxSubview.bottomAnchor),
        ])
        
        declBoxLabel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(withConfiguration conf: DeclCellConfiguration, refs: [String: Reference]) {
        let ctx = SyntaxToken.Context(isMakingAttributedStringForList: false,
                                      refs: refs,
                                      font: UIFont.monospacedSystemFont(ofSize: 15, weight: .regular))
        
        let attr = conf.decl.tokens.combiningAttributedStrings(with: ctx)
        declBoxLabel.attributedText = attr
        if conf.includePlatformNames {
            platformsLabel.text = conf.decl.platforms.joined(separator: ", ")
        } else {
            platformsLabel.isHidden = true
        }
    }
}

extension DeclarationCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("handling url \(url)")
        self.openURLFunction?(url.absoluteString)
        return false //?
    }
}
