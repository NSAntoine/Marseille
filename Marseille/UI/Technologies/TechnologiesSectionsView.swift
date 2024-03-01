//
//  TechnologiesSectionsView.swift
//  Marseille
//
//  Created by Serena on 25/03/2023.
//  

import SwiftUI

struct TechnologiesSectionsView: View {
	let sectionNames: [String]
	let sectionChangeHandler: (String) -> Void
	
	var body: some View {
		ScrollView(.horizontal) {
			LazyHStack {
				ForEach(sectionNames, id: \.self) { section in
					Button(section) {
						sectionChangeHandler(section)
					}
					.buttonStyle(.bordered)
				}
			}
		}
	}
}
