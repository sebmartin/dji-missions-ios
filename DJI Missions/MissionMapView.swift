//
//  MissionMap.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-03.
//

import SwiftUI
import MapKit

let SPAN_PADDING_FACTOR = 1.5

struct MissionMapView: UIViewRepresentable {
    @ObservedObject var mission: Mission
    
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var selectedPoint: MissionPoint?
    
    func makeUIView(context: Context) -> some MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        if let region = MissionMapView.pointsBoundingRegion(mission: mission) {
            mapView.region = region
        }
        if let overlay = mission.pathOverlay() {
            mapView.addOverlay(overlay)
        }
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        updateAnnotations(uiView)
        updateSelection(uiView)
    }
    
    func updateAnnotations(_ mapView: MKMapView) {
        guard let annotations = mapView.annotations as? [MissionPoint],
              let points = mission.points?.array as? [MissionPoint] else {
                  return
              }
        
        // Remove deleted annotations
        annotations.forEach { annotation in
            if !points.contains(annotation) {
                mapView.removeAnnotation(annotation)
            }
        }
        
        // Add new annotations
        points.forEach { point in
            if !annotations.contains(point) {
                mapView.addAnnotation(point)
            }
        }
    }
    
    func updateSelection(_ mapView: MKMapView) {
        if let selectedPoint = selectedPoint {
            mapView.selectAnnotation(selectedPoint, animated: true)
        } else {
            mapView.selectedAnnotations.forEach {
                mapView.deselectAnnotation($0, animated: true)
            }
        }
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
    
    // MARK: - Coordinator
    
    internal class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MissionMapView
        
        init(_ parent: MissionMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.latitude = mapView.region.center.latitude
            parent.longitude = mapView.region.center.longitude
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let selectedAnnotation = mapView.selectedAnnotations.first else {
                return
            }
            if let selectedPoint = selectedAnnotation as? MissionPoint {
                parent.selectedPoint = selectedPoint
            } else {
                print("Unknown selected annotation: \(selectedAnnotation)")
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.selectedPoint = nil
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let polyline as MKPolyline:
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.lineWidth = 1.5
                renderer.strokeColor = .gray
                renderer.lineDashPattern = [3, 3]
                return renderer
                
            default:
                fatalError("Unexpected MKOverlay type")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
