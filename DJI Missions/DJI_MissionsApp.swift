//
//  DJI_MissionsApp.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-02.
//

import SwiftUI

@main
struct DJI_MissionsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup() {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
