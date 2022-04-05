//
//  Mission+MKOverlay.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-04.
//

import MapKit

extension Mission {
    func pathOverlay() -> MKOverlay? {
        guard let points = points?.array as? [MissionPoint] else {
            return nil
        }
        let mapPoints = points.map { MKMapPoint(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)) }
        return MKPolyline(points: mapPoints, count: points.count)
    }
}
