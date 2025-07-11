//
//  LicensePlateList.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//

import SwiftUI

struct LicensePlateList: View {
    var body: some View {
        List {
            Section(Switzerland.countryName) {
                ForEach(Switzerland.getItems(), id: \.identifier) { item in
                    NavigationLink {
                        LicensePlateDetail(item: item)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.identifier)
                                .font(.headline)
                            Text(item.title)
                                .font(.subheadline)
                            if (!item.inUse) {
                                Text("(not in use)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            Section("Other countries") {
                Text("no data yet")
            }
        }
    }
}

#Preview {
    LicensePlateList()
}
