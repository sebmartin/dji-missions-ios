//
//  DroneView.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-05.
//

import SwiftUI
import DJISDK
import CoreData
import Logging

struct DroneView: View {
    @Environment(\.droneSDK) var droneSDK
    @Environment(\.managedObjectContext) private var viewContext
    let logger = Logger(suffix: "DroneView")

    @AppStorage("bridgeAppIP") var bridgeAppIP: String = ""
    @AppStorage("connectionType") var connectionType: ConnectionType = .bridge
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
                        if droneStatus.isReady() {
                            Button(action: cancelConnection) {
                                Text("Disconnect")
                            }
                            .foregroundColor(.red)
                        } else if droneStatus.disconnected() {
                            Button(action: connectToBridge) {
                                Text("Connect")
                            }
                        } else {
                            Button(action: cancelConnection) {
                                Text("Cancel")
                            }.foregroundColor(.red)
                        }
                    }
                    
                    if droneStatus.registrationUnderway() {
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
                logger.info("Received initialization status: \($0), registration underway: \($0.registrationUnderway())")
            }
            .onReceive(droneSDK.componentState) {
                componentState = $0
                logger.info("Received component state")
            }
            .navigationBarTitle("Drone Settings")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func connectToBridge() {
        DispatchQueue.main.async {
            droneSDK.initSDK(bridgeAppIP: bridgeAppIP) { result in
                switch result {
                case .success(_):
                    logger.info("SDK registration completed")
                case .failure(let error):
                    logger.error("Failed to register with SDK: \(error)")
                }
            }
        }
    }
    
    func cancelConnection() {
        droneSDK.disconnect()
    }
    
    func connectToDrone() {
        // TODO
    }
}

struct DroneView_Previews: PreviewProvider {
    static var previews: some View {
        DroneView()
    }
}
