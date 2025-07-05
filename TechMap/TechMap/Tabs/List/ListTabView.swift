//
//  ListTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import SwiftData
import CoreLocation

struct ListTabView: View {
    var firebaseVM: FirebaseVM
    var locationVM: LocationVM
    var companies: [Company]
    var checks: [Check]
    @Query var rawSettings: [Settings]
    @Environment(\.modelContext) private var modelContext
    
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
    
    private func calculateRegionFromLocation() -> Settings.Region {
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
    var checksWithAssociatedCompaniesInRegion: [CheckWithAssociatedCompany] {
        checksWithAssociatedCompanies
            .filter { region == .all || $0.company?.region == region.code }
    }
    var companiesInRegion: [Company] {
        companies
            .filter { region == .all || $0.region == region.code }
    }
    var checksWithAssociatedCompanies: [CheckWithAssociatedCompany] {
        checks
            .map { check in
                CheckWithAssociatedCompany(
                    check: check,
                    company: companies.first(where: { company in
                        company.id == check.companyId
                    })
                )
            }
            .sorted {
                $0.check.createdAt > $1.check.createdAt
            }
    }
    var notVisitedYet: [Company] {
        companiesInRegion
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
                // Region Picker
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
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 200)
                }
                
                
                // Visited companies
                Text("Visited (\(checks.count))")
                    .sectionTitle()
                
                if checksWithAssociatedCompaniesInRegion.isEmpty {
                    Text("You have not visited any companies yet. Click on a company on the map and select \"Mark as Visited\" to visit one.")
                        .padding(.vertical)
                        .padding(.bottom)
                } else {
                    List(checksWithAssociatedCompaniesInRegion, id: \CheckWithAssociatedCompany.check.id) { c in
                        if let company = c.company {
                            NavigationLink(value: company) {
                                HStack {
                                    InlineLogo(imageName: company.imageName)
                                    Text(company.name)
                                    Spacer()
                                    Text(JDateFormatter.formatRelatively(c.check.createdAt))
                                        .padding(.vertical, 4)
                                }
                            }
                        } else {
                            // Company doesn't exist anymore
                            // Text(c.check.companyId)
                            EmptyView()
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
                CompanyDetails(
                    company: .constant(company),
                    checks: checks,
                    firebaseVM: firebaseVM,
                    locationVM: locationVM,
                    closable: false,
                    onDirectionsRequested: nil
                )
                .padding()
            }
        }
    }
}


struct CheckWithAssociatedCompany {
    let check: Check
    let company: Company?
}

#Preview {
    ListTabView(firebaseVM: MockData.firebaseVM, locationVM: .init(), companies: MockData.companies, checks: MockData.checks)
}
