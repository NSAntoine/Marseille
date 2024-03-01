//
//  BasicLayoutAnchorsHolding.swift
//  Coirax
//
//  Created by Serena on 07/01/2023
//


import UIKit

/// A protocol describing a type with the basic layout anchors
/// used for constraining a view with `NSLayoutConstraint`
protocol BasicLayoutAnchorsHolding {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension BasicLayoutAnchorsHolding {
    /// Activate constraints to cover the target with the current item.
	func constraintCompletely<Target: BasicLayoutAnchorsHolding>(to target: Target,
																 leadingConstant: CGFloat = 0,
																 trailingConstant: CGFloat = 0,
																 topConstant: CGFloat = 0,
																 bottomConstant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: leadingConstant),
            trailingAnchor.constraint(equalTo: target.trailingAnchor, constant: trailingConstant),
            topAnchor.constraint(equalTo: target.topAnchor, constant: topConstant),
            bottomAnchor.constraint(equalTo: target.bottomAnchor, constant: bottomConstant)
        ])
    }
    
    /// Activate constraints to center the target with the current item.
    func centerConstraints<Target: BasicLayoutAnchorsHolding>(to target: Target) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: target.centerXAnchor),
            centerYAnchor.constraint(equalTo: target.centerYAnchor)
        ])
    }
}

extension UIView: BasicLayoutAnchorsHolding {}
extension UILayoutGuide: BasicLayoutAnchorsHolding {}
