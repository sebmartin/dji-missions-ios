//
//  DroneView.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-05.
//

import SwiftUI
import DJISDK

struct DroneView: View {
    @Environment(\.droneSDK) var droneSDK
    
    @State var bridgeAppIP: String = ""
    @State var connectionType: ConnectionType = .bridge
    @State var connectionStatus: String = ""
    
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
                        Button(action: connectToBridge) {
                            Text("Connect")
                        }
                        HStack{
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding([.trailing], 10)
                            Text(connectionStatus)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if case .drone = connectionType {
                    Section(header: Text("DJI Drone")) {
                        Button("Connect to DJI drone", action: connectToDrone)
                    }
                }
            }
            .navigationBarTitle("Drone Settings")
        }
        .onReceive(droneSDK.status) {
            connectionStatus = $0.description
        }
    }
    
    func connectToBridge() {
        droneSDK.initSDK(bridgeAppIP: bridgeAppIP) { result in
            switch result {
            case .success(_):
                print("SDK registration completed")
            case .failure(let error):
                print("Failed to register with SDK: \(error)")
            }
        }
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
