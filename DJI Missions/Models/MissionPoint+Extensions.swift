//
//  MissionPoint+Extensions.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-04.
//

import Foundation
import CoreData

extension MissionPoint {
    convenience init(_ latitude: Double, _ longitude: Double, context: NSManagedObjectContext) {
        self.init(context: context)
        self.latitude = latitude
        self.longitude = longitude
    }
}
