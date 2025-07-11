//
//  CountryList.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 12/07/2025.
//

import SwiftUI

struct CountryList: View {
    let countries = DbManager.instance.getCountries()
    
    var body: some View {
        List {
            ForEach(countries, id: \.id) { country in
                NavigationLink {
                    CountryDetail(country: country)
                } label: {
                    HStack(alignment: .center) {
                        if let flagEmoji = country.flagEmoji {
                            Text(flagEmoji)
                        } else {
                            Image(systemName: "flag")
                        }
                        Text(country.id)
                            .font(.headline)
                        Text(country.name)
                    }
                }
            }
        }
    }
}

#Preview {
    CountryList()
}
