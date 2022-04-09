//
//  DJI_MissionsApp.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-02.
//

import SwiftUI

private struct DroneSDKKey: EnvironmentKey {
    static var defaultValue: DroneSDK = DJIDroneSDK()
}

extension EnvironmentValues {
    var droneSDK: DroneSDK {
        get { self[DroneSDKKey.self] }
        set { self[DroneSDKKey.self] = newValue }
    }
}

@main
struct DJI_MissionsApp: App {
    let persistenceController = PersistenceController.shared
    let droneSDK = DJIDroneSDK()

    var body: some Scene {
        WindowGroup() {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.droneSDK, droneSDK)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
