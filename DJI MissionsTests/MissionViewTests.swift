//
//  MissionViewTests.swift
//  DJI MissionsTests
//
//  Created by Seb Martin on 2022-04-04.
//

import XCTest
import SwiftUI
import CoreData
@testable import DJI_Missions
import MapKit

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
}

extension MKCoordinateSpan: Equatable {}

public func ==(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
    return (lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta)
}

class MissionViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func missionNoPoints() -> Mission {
        let context = PersistenceController.preview.container.viewContext
        return Mission(context: context)
    }
    
    private func missionOverLibertyIslandFourPoints() -> Mission {
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

    func testPointsBoundingRegionOverLibertyIsland() throws {
        let mission = missionOverLibertyIslandFourPoints()
        let result = MissionMap.pointsBoundingRegion(mission: mission)
        
        XCTAssertEqual(result?.center, CLLocationCoordinate2D(
            latitude: 40.6897805,
            longitude: -74.045166
        ))
        
        XCTAssertEqual(result?.span, MKCoordinateSpan(
            latitudeDelta: 0.0032659000000002437,
            longitudeDelta: 0.004756399999996575
        ))
    }

    func testPointsBoundingRegionNoPoints() throws {
        let mission = missionNoPoints()
        let result = MissionMap.pointsBoundingRegion(mission: mission)
        
        XCTAssertNil(result)
    }
}
