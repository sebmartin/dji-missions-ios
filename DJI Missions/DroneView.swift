//
//  DroneView.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-05.
//

import SwiftUI
import DJISDK
import CoreData

struct DroneView: View {
    @Environment(\.droneSDK) var droneSDK
    @Environment(\.managedObjectContext) private var viewContext

    @State var bridgeAppIP: String = ""
    @State var connectionType: ConnectionType = .bridge
    @State var droneStatus: Drone.InitializationStatus = .disconnected
    @State var componentState: Drone.ComponentState = Drone.ComponentState()
    @State var registrationUnderway = false
    
    enum ConnectionType: String, CaseIterable, Identifiable {
        case drone
        case bridge
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Connection")) {
                    Picker("Type", selection: $connectionType) {
                        Text("DJI Drone").tag(ConnectionType.drone)
                        Text("Bridge").tag(ConnectionType.bridge)
                    }
                }
                
                if case .bridge = connectionType {
                    Section(header: Text("Bridge Settings")) {
                        TextField("IP Address", text: $bridgeAppIP)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .disabled(!droneStatus.disconnected())
                        if case .connectedToAircraft = droneStatus {
                            Button(action: cancelConnection) {
                                Text("Disconnect")
                            }
                            .foregroundColor(.red)
                        } else if !registrationUnderway {
                            Button(action: connectToBridge) {
                                Text("Connect")
                            }
                        } else {
                            Button(action: cancelConnection) {
                                Text("Cancel")
                            }.foregroundColor(.red)
                        }
                    }
                    
                    if registrationUnderway {
                        Section(header: Text("Status")) {
                            HStack{
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .padding([.trailing], 10)
                                Text(droneStatus.description)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                if case .drone = connectionType {
                    Section(header: Text("DJI Drone")) {
                        Button("Connect to DJI drone", action: connectToDrone)
                    }
                }
            }
            .onReceive(droneSDK.initializationStatus) {
                droneStatus = $0
                registrationUnderway = $0.registrationUnderway()
                print("Received initialization status: \($0), registration underway: \($0.registrationUnderway())")
            }
            .onReceive(droneSDK.componentState) {
                componentState = $0
                print("Received component state")
            }
            .navigationBarTitle("Drone Settings")
            .navigationBarItems(
                trailing:
                    Text("HI")
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func connectToBridge() {
        DispatchQueue.main.async {
            droneSDK.initSDK(bridgeAppIP: bridgeAppIP) { result in
                switch result {
                case .success(_):
                    print("SDK registration completed")
                case .failure(let error):
                    print("Failed to register with SDK: \(error)")
                }
            }
        }
    }
    
    func cancelConnection() {
        droneSDK.disconnect()
    }
    
    func connectToDrone() {
        let request = NSFetchRequest<Mission>(entityName: "Mission")
        request.fetchLimit = 1
        request.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]
        let result = try? viewContext.fetch(request)
        print(result ?? "No results to print")
    }
}

struct DroneView_Previews: PreviewProvider {
    static var previews: some View {
        DroneView()
    }
}
