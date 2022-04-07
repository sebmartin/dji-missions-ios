//
//  ContentView.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-02.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    var body: some View {
        TabView {
            DroneView()
                .tabItem {
                    Image(systemName: "airplane.circle")
                    Text("Drone")
                }
            MissionsView()
                .tabItem {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                    Text("Missions")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainTabView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).previewInterfaceOrientation(.portrait)
        }
    }
}
