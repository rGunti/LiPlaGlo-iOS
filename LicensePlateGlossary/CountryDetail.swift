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
    let links: [CountryLink]
    let plateVariants: [PlateVariant]
    let identifierTypes: [RegionalIdentifierType]
    @StateObject private var vm = CountryDetailViewObject()

    init(country: Country) {
        self.country = country
        self.links = DbManager.instance.getLinksForCountry(country.id, forLanguage: getCurrentLanguage(withFallback: defaultFallbackLanguage))
        self.plateVariants = DbManager.instance.getPlateVariantsForCountry(country.id)
        self.identifierTypes =
            DbManager.instance.getRegionalIdentifierTypes(forCountry: country.id)
    }
    
    var body: some View {
        List {
            if country.genericPreview != nil {
                Section("Generic License Plate Layout") {
                    LicensePlatePreview(
                        fromCountry: country
                    )
                }
            }
            
            if let description = country.description {
                Section("Description") {
                    Text(getTranslatedStringWithFormatting(description))
                }
            }

            if let vanityPlatesPossible = country.vanityPlatesPossible {
                Section("Vanity Plates") {
                    if vanityPlatesPossible, let vanityPlatesDescription = country.vanityPlatesDescription {
                        Text(getTranslatedStringWithFormatting(vanityPlatesDescription))
                    } else if vanityPlatesPossible {
                        Text("Vanity plates are available for this country.")
                    } else {
                        Text("Vanity plates are not available for this country.")
                    }
                }
            }
            
            Section("Regional Identifiers") {
                ForEach(identifierTypes, id: \.id) { identifierType in
                    NavigationLink {
                        RegionalIdentifierList(
                            type: identifierType,
                            country: country
                        )
                    } label: {
                        Text(getTranslatedString(identifierType.name))
                    }
                }
            }
            
            Section("Plate Variants") {
                ForEach(plateVariants, id: \.id) { variant in
                    NavigationLink {
                        PlateVariantDetails(plateVariant: variant, country: country)
                    } label: {
                        GeometryReader { geo in
                            HStack(alignment: .firstTextBaseline) {
                                LicensePlatePreview(
                                    fromPlateVariant: variant,
                                    andCountry: country,
                                    withTextSize: 20,
                                    withBorderSize: 2
                                )
                                .frame(
                                    width: geo.size.width * 0.5,
                                    height: geo.size.height)
                                Text(getTranslatedStringWithFormatting(variant.title))
                                    .frame(
                                        width: geo.size.width * 0.5,
                                        height: geo.size.height,
                                        alignment: .leading)
                            }
                        }
                    }
                }
            }
            
            if links.count > 0 {
                Section("Links") {
                    ForEach(links, id: \.link) { link in
                        Link(destination: URL(string: link.link)!) {
                            if let linkLabel = link.label {
                                Label(
                                    getTranslatedString(linkLabel),
                                    systemImage: "link"
                                )
                            } else {
                                Label(link.link, systemImage: "link")
                            }
                        }
                    }
                }
            }
            
            Section("Where is \(getTranslatedString(country.name))?") {
                Map(position: $vm.camera) {
                    if let markerItem = vm.location {
                        Marker(
                            coordinate: markerItem
                        ) {
                            TranslatedText(country.name)
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
        .navigationTitle(getTranslatedString(country.name))
    }
}

@MainActor
final class CountryDetailViewObject: ObservableObject {
    @Published var camera: MapCameraPosition = .automatic
    @Published var location: CLLocationCoordinate2D? = nil

    func load(_ country: Country) {
        Task {
            let translatedCountryName = getTranslatedString(country.name)
            let placemarks = try await CLGeocoder().geocodeAddressString(translatedCountryName)
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
        item.name = getTranslatedString(name)
        item.openInMaps()
    }
}

#Preview {
    CountryDetail(country: Country(
        id: "XX",
        name: "country_xx",
        flagEmoji: "🏳️",
        defaultFont: "Swiss License Plates",
        //genericPreview: "AB : CD 1234"
        genericPreview: "XX·123 456",
        description: "raw:**Hello** _World_",
        vanityPlatesPossible: true,
        vanityPlatesDescription: "raw: **Some** _Text_"
    ))
}
