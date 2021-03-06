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

    func testPointsBoundingRegionOverLibertyIsland() throws {
        let mission = CoreDataFixtures.missionOverLibertyIslandFourPoints()
        let result = MissionMapView.pointsBoundingRegion(mission: mission)
        
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
        let mission = CoreDataFixtures.missionNoPoints()
        let result = MissionMapView.pointsBoundingRegion(mission: mission)
        
        XCTAssertNil(result)
    }
}
