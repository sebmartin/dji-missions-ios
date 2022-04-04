//
//  MissionMap.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-03.
//

import SwiftUI
import MapKit

struct MissionMap: UIViewRepresentable {
    @Binding var annotations: [MissionPoint]
    
    func makeUIView(context: Context) -> some UIView {
        let mapView = MKMapView()
//        mapView.showsUserLocation = true
//        mapView.setCenter(mapView.userLocation.coordinate, animated: false)
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
