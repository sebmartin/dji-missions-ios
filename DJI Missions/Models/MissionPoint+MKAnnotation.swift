//
//  MissionPoint+MKAnnotation.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-04.
//

import MapKit

extension MissionPoint: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
