//
//  ListTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import SwiftData
import CoreLocation
import MapKit

struct ListTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var firebaseVM: FirebaseVM
    var locationVM: LocationVM
    var companies: [Company]
    var checks: [Check]
    @Binding var selectedCompany: Company?
    @Binding var selectedTab: String
    @Binding var cameraPosition: MapCameraPosition
    
    @Query var rawSettings: [Settings]
    
    @State private var searchText = ""

    // Computed properties
    var region: Settings.Region {
        if let settings = rawSettings.first {
            if let region = settings.region {
                return region
            } else {
                // calculate region using user's location
                return calculateRegionFromLocation()
            }
        } else {
            return .all
        }
    }
    
    var checksWithAssociatedCompaniesInRegion: [CheckWithAssociatedCompany] {
        checksWithAssociatedCompanies
            .filter { region == .all || $0.company.region == region.code }
    }
    var checksWithAssociatedCompaniesInRegionMatchingSearch: [CheckWithAssociatedCompany] {
        checksWithAssociatedCompaniesInRegion
            .filter {
                searchText.isEmpty || $0.company.name.localizedCaseInsensitiveContains(searchText)
            }
    }
    var companiesInRegion: [Company] {
        companies
            .filter { region == .all || $0.region == region.code }
    }
    var companiesInRegionMatchingSearch: [Company] {
        companiesInRegion
            .filter {
                searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
            }
    }
    var checksWithAssociatedCompanies: [CheckWithAssociatedCompany] {
        checks
            .map { check in
                if let company = companies.first(where: { company in
                    company.id == check.companyId
                }) {
                    CheckWithAssociatedCompany(
                        check: check,
                        company: company
                    )
                } else {
                    CheckWithAssociatedCompany.toRemove
                }
            }
            .filter { $0.check.companyId != CheckWithAssociatedCompany.deleteMeCompanyId }
            .sorted {
                $0.check.createdAt > $1.check.createdAt
            }
    }
    var notVisitedYet: [Company] {
        companiesInRegionMatchingSearch
            .filter {
                !companyChecked(company: $0, checks: checks)
            }
            .sorted {
                $0.name < $1.name
            }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Visited companies
                Text("Visited (\(checksWithAssociatedCompaniesInRegionMatchingSearch.count))")
                    .sectionTitle()
                
                if checksWithAssociatedCompaniesInRegionMatchingSearch.isEmpty {
                    Text("You have not visited any companies \(region == .all ? "" : "in \(region.fullDescription) ")yet. Click on a company on the map and select \"Mark as Visited\" to visit one.")
                        .padding(.vertical)
                        .padding(.bottom)
                } else {
                    List(checksWithAssociatedCompaniesInRegionMatchingSearch, id: \CheckWithAssociatedCompany.check.id) { c in
                        NavigationLink(value: c.company) {
                            HStack {
                                InlineLogo(imageName: c.company.imageName)
                                Text(c.company.name)
                                Spacer()
                                Text(JDateFormatter.formatRelatively(c.check.createdAt))
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                
                // Companies that have not been visited yet
                Text("Not Visited Yet (\(notVisitedYet.count))")
                    .sectionTitle()
                
                List(notVisitedYet) { company in
                    NavigationLink(value: company) {
                        HStack {
                            InlineLogo(imageName: company.imageName)
                            Text(company.name)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding()
            .navigationDestination(for: Company.self) { company in
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            // selectedCompany = company //Don't select the company because that shows the CompanyDetails which the user just came from
                            selectedTab = Constants.mapTabValue
                            cameraPosition = zoomTo(coordinate: .init(latitude: company.lat, longitude: company.lng), radius: 1000)
                        } label: {
                            Label("Show in TechMap", systemImage: Constants.mapIcon)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    CompanyDetails(
                        company: .constant(company),
                        checks: checks,
                        firebaseVM: firebaseVM,
                        locationVM: locationVM,
                        closable: false,
                        onDirectionsRequested: nil
                    )
                }
                .padding(.horizontal)
            }
            .overlay(alignment: .topTrailing) {
                if let settings = rawSettings.first {
                    Picker(
                        "Region",
                        selection: .init(get: { region }, set: { newValue in
                            settings.region = newValue
                            try? modelContext.save()
                        })
                    ) {
                        Text(Settings.Region.bayArea.rawValue)
                            .tag(Settings.Region.bayArea)
                        Text(Settings.Region.nyc.rawValue)
                            .tag(Settings.Region.nyc)
                        Text(Settings.Region.seattle.rawValue)
                            .tag(Settings.Region.seattle)
                        Text(Settings.Region.all.rawValue)
                            .tag(Settings.Region.all)
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .padding(.top, 10)
                    .padding(.trailing, 20)
                }
            }
            .searchable(text: $searchText)
        }
    }
    
    private func calculateRegionFromLocation() -> Settings.Region { //written by Claude code
        guard let currentLocation = locationVM.currentLocation else {
            return .all
        }
        
        let coordinate = currentLocation.coordinate
        
        // NYC boundaries (approximate)
        let nycBounds = (
            minLat: 40.4774, maxLat: 40.9176,
            minLon: -74.2591, maxLon: -73.7004
        )
        
        // Bay Area boundaries (approximate)
        let bayAreaBounds = (
            minLat: 37.1, maxLat: 38.0,
            minLon: -122.8, maxLon: -121.2
        )
        
        // Seattle Metro boundaries (approximate)
        let seattleBounds = (
            minLat: 47.0, maxLat: 47.8,
            minLon: -122.8, maxLon: -121.5
        )
        
        // Check if location is within NYC bounds
        if coordinate.latitude >= nycBounds.minLat && coordinate.latitude <= nycBounds.maxLat &&
           coordinate.longitude >= nycBounds.minLon && coordinate.longitude <= nycBounds.maxLon {
            return .nyc
        }
        
        // Check if location is within Bay Area bounds
        if coordinate.latitude >= bayAreaBounds.minLat && coordinate.latitude <= bayAreaBounds.maxLat &&
           coordinate.longitude >= bayAreaBounds.minLon && coordinate.longitude <= bayAreaBounds.maxLon {
            return .bayArea
        }
        
        // Check if location is within Seattle Metro bounds
        if coordinate.latitude >= seattleBounds.minLat && coordinate.latitude <= seattleBounds.maxLat &&
           coordinate.longitude >= seattleBounds.minLon && coordinate.longitude <= seattleBounds.maxLon {
            return .seattle
        }
        
        // If location doesn't match any specific region, return all
        return .all
    }
}


struct CheckWithAssociatedCompany {
    let check: Check
    let company: Company
    
    static let deleteMeCompanyId = "DELETE ME"
    static let toRemove = CheckWithAssociatedCompany(check: .init(companyId: deleteMeCompanyId, userId: "", createdAt: .now, device: ""), company: MockData.companies[0])
}

//#Preview {
//    ListTabView(firebaseVM: MockData.firebaseVM, locationVM: .init(), companies: MockData.companies, checks: MockData.checks)
//}

