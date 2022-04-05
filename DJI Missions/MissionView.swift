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
        case selectedPoint(MissionPoint)
        case appendFirst
        case appendBefore(MissionPoint)
        case appendAfter(MissionPoint)
        
        func isEditing() -> Bool {
            switch self {
            case .view:
                return false
            case .selectedPoint:
                return false
            default:
                return true
            }
        }
    }
    
    init(mission: Mission) {
        self.mission = mission
        let pointCount = mission.points?.count ?? 0
        self.viewMode = pointCount > 0 ? .view : .appendFirst
        print("view mode: \(self.viewMode)")
    }
    
    var body: some View {
        ZStack {
            MissionMapView(mission: mission, latitude: $latitude, longitude: $longitude)
                .onPointSelectionChange { selectedPoint in
                    if let selectedPoint = selectedPoint {
                        viewMode = .selectedPoint(selectedPoint)
                    } else {
                        viewMode = .view
                    }
                }
                .edgesIgnoringSafeArea([.top, .trailing, .leading])
                
            VStack {
                Text("\(latitude), \(longitude)")
                Spacer()
                
                if case .selectedPoint(let selectedPoint) = viewMode {
                    SelectedPointControls(viewMode: $viewMode, point: selectedPoint, onDeletePoint: { delete(point: $0) })
                } else if case .appendFirst = viewMode {
                    InsertPointControls(viewMode: $viewMode, okText: "Set Starting Point", cancelText: "Cancel") {
                        let point = insertPoint()
                        viewMode = .appendAfter(point)
                    }
                } else if case .appendBefore(let point) = viewMode {
                    InsertPointControls(viewMode: $viewMode, okText: "Set Next Point", cancelText: "Done") {
                        _ = insertPoint(before: point)
                        viewMode = .view
                    }
                } else if case .appendAfter(let point) = viewMode {
                    InsertPointControls(viewMode: $viewMode, okText: "Set Next Point", cancelText: "Done") {
                        let newPoint = insertPoint(after: point)
                        if selectedPoint == point {
                            viewMode = .view
                        } else {
                            viewMode = .appendAfter(newPoint)
                        }
                    }
                } else if case .view = viewMode {
                    Text("View mode")
                }
            }
            if viewMode.isEditing() {
                Target(size: 40)
                    .foregroundColor(.red)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private func insertPoint(after: MissionPoint? = nil) -> MissionPoint {
        let newPoint = MissionPoint(latitude, longitude, context: viewContext)
        
        if let after = after, let pointIndex = mission.points?.index(of: after) {
            mission.insertIntoPoints(newPoint, at: pointIndex)
        } else {
            mission.addToPoints(newPoint)
        }
        try? viewContext.save()
        return newPoint
    }
        
    private func insertPoint(before: MissionPoint) -> MissionPoint {
        let newPoint = MissionPoint(latitude, longitude, context: viewContext)
        
        if let pointIndex = mission.points?.index(of: before) {
            mission.insertIntoPoints(newPoint, at: pointIndex + 1)
        } else {
            print("WARN - failed to insert new point before \(before)")
            mission.addToPoints(newPoint)
        }
        try? viewContext.save()
        return newPoint
    }
    
    private func delete(point: MissionPoint) {
        mission.removeFromPoints(point)
        try? viewContext.save()
    }
    
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
        @Binding var viewMode: ViewMode
        var point: MissionPoint
        let onDeletePoint: (MissionPoint) -> Void

        var body: some View {
            VStack {
                HStack {
                    ControlButton(text: "Insert Before", systemImage: "arrow.uturn.backward.circle") {
                        viewMode = .appendBefore(point)
                    }
                    Spacer()
                    ControlButton(text: "Insert After", systemImage: "arrow.uturn.right.circle") {
                        viewMode = .appendAfter(point)
                    }
                }
                HStack {
                    ControlButton(text: "Move", systemImage: "arrow.up.and.down.and.arrow.left.and.right") {
                        // TODO
                    }
                    Spacer()
                    ControlButton(text: "Delete", systemImage: "minus.circle") {
                        onDeletePoint(point)
                        viewMode = .view
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
