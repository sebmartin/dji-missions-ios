//
//  MissionView.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-02.
//

import SwiftUI
import MapKit

struct MissionView: View {
    var item: Mission
    
    @State private var showAlert = false
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @State var annotations = [MissionPoint]()
    
    @State var isEditing = false
    
    var body: some View {
        ZStack {
            
            MissionMap(annotations: $annotations)
                .edgesIgnoringSafeArea([.top, .trailing, .leading])
            VStack {
                Spacer()
                if isEditing {
                    HStack {
                        Button(action: savePoint) {
                            Text("Save")
                        }
                        .buttonStyle(.bordered)
                        .padding([.bottom, .leading], 30)
                        Spacer()
                        Button(action: { isEditing = !isEditing }) {
                            Text("Cancel")
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
        isEditing = !isEditing
    }
}

struct Target: View {
    var size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: size / 15.0, antialiased: true)
            Circle()
                .frame(width: 4.0, height: 4.0, alignment: .center)
            HStack {
                Group{
                    VStack {
                        Triangle()
                            .rotation(Angle(degrees: 135))
                            .scale(1.2)
                        Triangle()
                            .rotation(Angle(degrees: 45))
                            .scale(1.2)
                    }
                    VStack {
                        Triangle()
                            .rotation(Angle(degrees: -135))
                            .scale(1.2)
                        Triangle()
                            .rotation(Angle(degrees: -45))
                            .scale(1.2)
                    }
                }
            }
        }.frame(width: size, height: size, alignment: .center)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct MissionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let mission = Mission(context: PersistenceController.preview.container.viewContext)
            MissionView(item: mission).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).previewInterfaceOrientation(.portrait)
        }
    }
}
