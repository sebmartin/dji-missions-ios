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
    
    var body: some View {
        ZStack {
            MissionMap(annotations: $annotations)
                .edgesIgnoringSafeArea([.top, .trailing, .leading])
            VStack {
                Spacer()
                Button(action: { print("Add") }) {
                    Label("Add Point", systemImage: "mappin.circle.fill")
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 20)
            }
        }
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
