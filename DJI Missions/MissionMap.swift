//
//  MissionMap.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-03.
//

import SwiftUI
import MapKit

let SPAN_PADDING_FACTOR = 1.1

struct MissionMap: UIViewRepresentable {
    @ObservedObject var mission: Mission
    
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    func makeUIView(context: Context) -> some UIView {
        let mapView = MKMapView()
        
        let region = MissionMap.pointsBoundingRegion(mission: mission)
        if let region = region {
            mapView.region = region
            latitude = region.center.latitude
            longitude = region.center.longitude
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    static func pointsBoundingRegion(mission: Mission) -> MKCoordinateRegion? {
        guard let points = mission.points?.array as? [MissionPoint] else {
            return nil
        }
        guard !points.isEmpty else {
            return nil
        }
                
        let minCoord = CLLocationCoordinate2D(latitude: -999, longitude: -999)
        let maxCoord = CLLocationCoordinate2D(latitude: 999, longitude: 999)
        let cornerPoints = points
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            .reduce((maxCoord, minCoord)) { result, coord in
                return (
                    CLLocationCoordinate2D(
                        latitude: min(result.0.latitude, coord.latitude),
                        longitude: min(result.0.longitude, coord.longitude)),
                    CLLocationCoordinate2D(
                        latitude: max(result.1.latitude, coord.latitude),
                        longitude: max(result.1.longitude, coord.longitude))
                )
            }
        
        let center = CLLocationCoordinate2D(
            latitude: (cornerPoints.1.latitude + cornerPoints.0.latitude) / 2.0,
            longitude: (cornerPoints.1.longitude + cornerPoints.0.longitude) / 2.0
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (cornerPoints.1.latitude - cornerPoints.0.latitude) * SPAN_PADDING_FACTOR,
            longitudeDelta: (cornerPoints.1.longitude - cornerPoints.0.longitude) * SPAN_PADDING_FACTOR
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}
