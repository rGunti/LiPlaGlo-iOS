//
//  CountryView.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 13/07/2025.
//

import SwiftUI

struct CountryView: View {
    var body: some View {
        NavigationStack {
            CountryList()
                .navigationTitle("Countries")
        }
    }
}

#Preview {
    CountryView()
}
