//
//  CountryDetail.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 12/07/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct CountryDetail: View {
    let country: Country
    @StateObject private var vm = CountryDetailViewObject()

    init(country: Country) {
        self.country = country
    }
    
    var body: some View {
        List {
            if let genericPreview = country.genericPreview {
                Section("Generic License Plate Layout") {
                    let preview = Text(genericPreview)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    if let licensePlateFont = country.defaultFont {
                        preview
                            .font(.custom(licensePlateFont, size: 64))
                            .italic(true)
                    } else {
                        preview.font(.largeTitle)
                    }
                }
            }
            
            Section("Where is \(country.name)?") {
                Map(position: $vm.camera) {
                    if let markerItem = vm.location {
                        Marker(
                            coordinate: markerItem
                        ) {
                            Text(country.name)
                        }
                    }
                }
                .task { vm.load(country) }
                .frame(height: 250)
                
                Button {
                    vm.openInMaps(named: country.name)
                } label: {
                    Label("Show on Maps", systemImage: "map.circle")
                }
            }
        }
        .navigationTitle(country.name)
    }
}

@MainActor
final class CountryDetailViewObject: ObservableObject {
    @Published var camera: MapCameraPosition = .automatic
    @Published var location: CLLocationCoordinate2D? = nil

    func load(_ country: Country) {
        Task {
            let placemarks = try await CLGeocoder().geocodeAddressString(country.name)
            if let loc = placemarks.first?.location {
                // Start with the same 8 × 8 deg span,
                // then wrap it in a camera position
                let region = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: .init(latitudeDelta: 8, longitudeDelta: 8)
                )
                print("Loaded", region)
                
                camera = .region(region)
                location = loc.coordinate
            }
        }
    }
    
    func openInMaps(named name: String) {
        guard let location else { return }
        
        let placemark = MKPlacemark(coordinate: location)
        let item = MKMapItem(placemark: placemark)
        item.name = name
        item.openInMaps()
    }
}

#Preview {
    CountryDetail(country: Country(
        id: "XX",
        name: "Example Country",
        flagEmoji: "🏳️",
        defaultFont: "Swiss License Plates",
        //genericPreview: "AB : CD 1234"
        genericPreview: "XX·123 456"
    ))
}
