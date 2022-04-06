//
//  CoreDataFixtures.swift
//  DJI MissionsTests
//
//  Created by Seb Martin on 2022-04-05.
//

import Foundation
@testable import DJI_Missions

struct CoreDataFixtures {
    static func missionNoPoints() -> Mission {
        let context = PersistenceController.preview.container.viewContext
        return Mission(context: context)
    }
    
    static func missionOverLibertyIslandFourPoints() -> Mission {
        let context = PersistenceController.preview.container.viewContext
        let mission = missionNoPoints()
        mission.points = [
            MissionPoint(40.691265, -74.047328, context: context),
            MissionPoint(40.690484, -74.043004, context: context),
            MissionPoint(40.688296, -74.045483, context: context),
            MissionPoint(40.691265, -74.047328, context: context),
        ]
        return mission
    }
}
