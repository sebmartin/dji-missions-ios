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
    @State var isEditing = false
    @State var latitude = 0.0
    @State var longitude = 0.0
    @State var selectedPoint: MissionPoint? = nil
    
    var body: some View {
        ZStack {
            MissionMapView(mission: mission, latitude: $latitude, longitude: $longitude, selectedPoint: $selectedPoint)
                .edgesIgnoringSafeArea([.top, .trailing, .leading])
            VStack {
                Text("\(latitude), \(longitude)")
                Spacer()
                if isEditing {
                    HStack {
                        Button(action: savePoint) {
                            Label("Add Point", systemImage: "mappin.and.ellipse")
                        }
                        .buttonStyle(.bordered)
                        .padding([.bottom, .leading], 30)
                        Spacer()
                        if let point = selectedPoint {
                            Text("\(point.latitude), \(point.longitude)")
                            Spacer()
                        }
                        Button(action: { isEditing = !isEditing }) {
                            Label("Done", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(.bordered)
                        .padding([.bottom, .trailing], 30)
                    }
                } else {
                    Button(action: addPoint) {
                        Label("Add Point", systemImage: "mappin.circle.fill")
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 30)
                }
            }
            if isEditing {
                Target(size: 40)
                    .foregroundColor(.red)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private func addPoint() {
        isEditing = !isEditing
    }
    
    private func savePoint() {
        let newPoint = MissionPoint(latitude, longitude, context: viewContext)
        mission.addToPoints(newPoint)
        try? viewContext.save()
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
