//
//  KeyValueRow.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 14/07/2025.
//

import SwiftUI

struct KeyValueRow: View {
    let key: String
    let value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(key): \(value)")
    }
}

#Preview {
    KeyValueRow(
        key: "Key",
        value: "Value"
    )
}
