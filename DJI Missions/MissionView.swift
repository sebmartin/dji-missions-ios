//
//  MissionView.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-02.
//

import SwiftUI
import MapKit


struct MissionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var mission: Mission
    @State var viewMode: ViewMode
    @State var latitude = 0.0
    @State var longitude = 0.0
    @State var selectedPoint: MissionPoint? = nil
    
    enum ViewMode {
        case view
        case insertFirst
        case insertBefore(MissionPoint)
        case insertAfter(MissionPoint)
        case movePoint(MissionPoint)
        
        func isEditing() -> Bool {
            switch self {
            case .view:
                return false
            default:
                return true
            }
        }
    }
    
    init(mission: Mission) {
        self.mission = mission
        let pointCount = mission.points?.count ?? 0
        self.viewMode = pointCount > 0 ? .view : .insertFirst
    }
    
    var body: some View {
        ZStack {
            MissionMapView(mission: mission, latitude: $latitude, longitude: $longitude, selectedPoint: $selectedPoint)
                .edgesIgnoringSafeArea([.top, .trailing, .leading])
                
            VStack {
                #if DEBUG
                Text("\(latitude), \(longitude)")
                #endif
                Spacer()
                
                if let selectedPoint = selectedPoint {
                    SelectedPointControls(
                        point: selectedPoint,
                        onInsertBefore: {
                            self.selectedPoint = nil
                            viewMode = .insertBefore($0)
                        },
                        onInsertAfter: {
                            self.selectedPoint = nil
                            viewMode = .insertAfter($0)
                        },
                        onMovePoint: {
                            self.selectedPoint = nil
                            viewMode = .movePoint($0)
                        },
                        onDeletePoint: { delete(point: $0) })
                } else if case .insertFirst = viewMode {
                    InsertPointControls(viewMode: $viewMode, okText: "Set Starting Point", cancelText: "Cancel") {
                        let point = insertPoint()
                        viewMode = .insertAfter(point)
                    }
                } else if case .insertBefore(let point) = viewMode {
                    InsertPointControls(viewMode: $viewMode, okText: "Add Point", cancelText: "Done") {
                        _ = insertPoint(before: point)
                        viewMode = .view
                    }
                } else if case .insertAfter(let point) = viewMode {
                    InsertPointControls(viewMode: $viewMode, okText: "Add Point", cancelText: "Done") {
                        let newPoint = insertPoint(after: point)
                        if selectedPoint != nil {
                            viewMode = .view
                        } else {
                            viewMode = .insertAfter(newPoint)
                        }
                    }
                } else if case .movePoint(let point) = viewMode {
                    InsertPointControls(viewMode: $viewMode, okText: "Save", cancelText: "Cancel") {
                        move(point: point, to: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                        viewMode = .view
                    }
                } else if case .view = viewMode {
                    
                }
            }
            if viewMode.isEditing() {
                Target(size: 40)
                    .foregroundColor(.red)
                    .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: - CRUD
    
    private func insertPoint(after: MissionPoint? = nil) -> MissionPoint {
        let newPoint = MissionPoint(latitude, longitude, context: viewContext)
        
        if let after = after, let pointIndex = mission.points?.index(of: after) {
            mission.insertIntoPoints(newPoint, at: pointIndex + 1)
        } else {
            mission.addToPoints(newPoint)
        }
        try? viewContext.save()
        return newPoint
    }
        
    private func insertPoint(before: MissionPoint) -> MissionPoint {
        let newPoint = MissionPoint(latitude, longitude, context: viewContext)
        
        if let pointIndex = mission.points?.index(of: before) {
            mission.insertIntoPoints(newPoint, at: pointIndex)
        } else {
            print("WARN - failed to insert new point before \(before)")
            mission.addToPoints(newPoint)
        }
        try? viewContext.save()
        return newPoint
    }
    
    private func move(point: MissionPoint, to coordinate: CLLocationCoordinate2D) {
        point.latitude = coordinate.latitude
        point.longitude = coordinate.longitude
        try? viewContext.save()
    }
    
    private func delete(point: MissionPoint) {
        mission.removeFromPoints(point)
        try? viewContext.save()
    }
    
    // MARK: - Controls Views
    
    struct InsertPointControls: View {
        @Binding var viewMode: ViewMode
        let okText: String
        let cancelText: String
        let insertAction: () -> Void
        
        var body: some View {
            HStack {
                ControlButton(text: okText, systemImage: "mappin.and.ellipse", action: insertAction)
                Spacer()
                ControlButton(text: cancelText, systemImage: "xmark.app", action: cancel)
            }
        }
        
        func cancel() {
            viewMode = .view
        }
    }
    
    struct SelectedPointControls: View {
        var point: MissionPoint
        let onInsertBefore: (MissionPoint) -> Void
        let onInsertAfter: (MissionPoint) -> Void
        let onMovePoint: (MissionPoint) -> Void
        let onDeletePoint: (MissionPoint) -> Void

        var body: some View {
            VStack {
                HStack {
                    ControlButton(text: "Insert Before", systemImage: "arrow.uturn.backward.circle") {
                        onInsertBefore(point)
                    }
                    Spacer()
                    ControlButton(text: "Insert After", systemImage: "arrow.uturn.right.circle") {
                        onInsertAfter(point)
                    }
                }
                HStack {
                    ControlButton(text: "Move", systemImage: "arrow.up.and.down.and.arrow.left.and.right") {
                        onMovePoint(point)
                    }
                    Spacer()
                    ControlButton(text: "Delete", systemImage: "minus.circle") {
                        onDeletePoint(point)
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    struct ControlButton: View {
        let text: String
        let systemImage: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Label(text, systemImage: systemImage)
            }
            .buttonStyle(.bordered)
            .padding([.bottom], 30)
            .padding([.leading, .trailing], 10)
        }
    }
}

struct MissionView_Previews: PreviewProvider {
    static func previewMission() -> Mission {
        let context = PersistenceController.preview.container.viewContext
        let mission = Mission(context: context)
        mission.points = [
            MissionPoint(40.691265, -74.047328, context: context),
            MissionPoint(40.690484, -74.043004, context: context),
            MissionPoint(40.688296, -74.045483, context: context),
            MissionPoint(40.691265, -74.047328, context: context),
        ]
        return mission
    }
    
    static var previews: some View {
        Group {
            MissionView(mission: previewMission())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .previewInterfaceOrientation(.portrait)
        }
    }
}
