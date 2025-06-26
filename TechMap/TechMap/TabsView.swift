//
//  TabsView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI

struct TabsView: View {
    var body: some View {
        TabView {
            Tab("Map", systemImage: "mappin.circle.fill") {
                MapTabView()
            }
            Tab("List", systemImage: "list.bullet") {
                MapTabView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsTabView()
            }
        }
    }
}

#Preview {
    TabsView()
}
