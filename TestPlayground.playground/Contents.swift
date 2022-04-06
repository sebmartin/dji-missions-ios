import UIKit
import MapKit

var bytes: [UInt8] = [39, 77, 111, 111, 102, 33, 39, 0]
let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
uint8Pointer.initialize(from: &bytes, count: 8)

uint8Pointer
uint8Pointer.pointee

let coordinates = [
    CLLocationCoordinate2D(latitude: 1, longitude: 1),
    CLLocationCoordinate2D(latitude: 2, longitude: 2)
]
let overlay = MKPolyline(coordinates: coordinates, count: 2)

overlay.pointCount

let x = (0...overlay.pointCount - 1).map { overlay.points()[$0] as MKMapPoint }.map { $0.coordinate }
x
