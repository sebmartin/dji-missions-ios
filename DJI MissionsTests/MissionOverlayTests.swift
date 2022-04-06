//
//  MissionOverlayTests.swift
//  DJI MissionsTests
//
//  Created by Seb Martin on 2022-04-05.
//

import XCTest
@testable import DJI_Missions

class MissionOverlayTests: XCTestCase {
    
    var observation: NSKeyValueObservation?
    
    override func tearDown() {
        observation = nil
    }

    func testExample() throws {
        @objc class Person: NSObject {
            @objc dynamic var name = "Taylor Swift"
        }

        let taylor = Person()
        _ = taylor.observe(\Person.name, options: .new) { person, change in
            print("I'm now called \(person.name)")
        }
        
    }
}
