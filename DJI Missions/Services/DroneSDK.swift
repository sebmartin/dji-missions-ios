//
//  DroneSDK.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-05.
//

import UIKit
import DJISDK
import Combine

protocol DroneSDK {
    typealias CompletionHandler = (Result<Void, Drone.Error>) -> Void
    
    var initializationStatus: AnyPublisher<Drone.InitializationStatus, Never> { get }
    var componentState: AnyPublisher<Drone.ComponentState, Never> { get }

    func initSDK(bridgeAppIP: String?, completionHandler handler: @escaping CompletionHandler) -> Void
    func disconnect()
}

struct Drone {
    enum InitializationStatus: CustomStringConvertible {
        case disconnected
        case registering
        case waitingForAircraft
        case connectedToAircraft
        case registrationFailed(Swift.Error)
        case aircraftConnectionTimeout
        
        var description: String {
            switch self {
            case .disconnected: return "Not started"
            case .registering: return "Registering"
            case .waitingForAircraft: return "Connecting to aircraft"
            case .connectedToAircraft: return "Connected to aircraft"
            case .registrationFailed: return "Registration failed"
            case .aircraftConnectionTimeout: return "Failed to connect; ensure the controller is paired with the airfcraft"
            }
        }
        
        func disconnected() -> Bool {
            if case .disconnected = self {
                return true
            }
            return false
        }
        
        func registrationUnderway() -> Bool {
            switch self {
            case .registering: fallthrough
            case .waitingForAircraft:
                return true
            default:
                return false
            }
        }
        
        func isReady() -> Bool {
            if case .connectedToAircraft = self {
                return true
            }
            return false
        }
        
        func isErrorState() -> Bool {
            switch self {
            case .registrationFailed: fallthrough
            case .aircraftConnectionTimeout:
                return true
            default:
                return false
            }
        }
    }
    
    struct ComponentState {
        enum State {
            case available
            case unavailable
            
            init(_ isConnected: Bool) {
                if isConnected {
                    self = .available
                } else {
                    self = .unavailable
                }
            }
        }
        
        struct Component {
            var name: String
            var states = [UInt:State]()
        }
        
        var AccessoryAggregation = Component(name:"AccessoryAggregation")
        var Lidar = Component(name:"Lidar")
        var RTKBaseStation = Component(name:"RTKBaseStation")
        var airLink = Component(name:"airLink")
        var battery = Component(name:"battery")
        var camera = Component(name:"camera")
        var flightController = Component(name:"flightController")
        var gimbal = Component(name:"gimbal")
        var payload = Component(name:"payload")
        var radar = Component(name:"radar")
        var remoteController = Component(name:"remoteController")
        
        subscript(name: String) -> Component? {
            get {
                switch name {
                case "AccessoryAggregation": return self.AccessoryAggregation
                case "Lidar": return self.Lidar
                case "RTKBaseStation": return self.RTKBaseStation
                case "airLink": return self.airLink
                case "battery": return self.battery
                case "camera": return self.camera
                case "flightController": return self.flightController
                case "gimbal": return self.gimbal
                case "payload": return self.payload
                case "radar": return self.radar
                case "remoteController": return self.remoteController
                default:
                    return nil
                }
            }
            set {
                if let newValue = newValue {
                    switch name {
                    case "AccessoryAggregation": self.AccessoryAggregation = newValue
                    case "Lidar": self.Lidar = newValue
                    case "RTKBaseStation": self.RTKBaseStation = newValue
                    case "airLink": self.airLink = newValue
                    case "battery": self.battery = newValue
                    case "camera": self.camera = newValue
                    case "flightController": self.flightController = newValue
                    case "gimbal": self.gimbal = newValue
                    case "payload": self.payload = newValue
                    case "radar": self.radar = newValue
                    case "remoteController": self.remoteController = newValue
                    default:
                        print("Invalid drone component key: \(newValue)")
                    }
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        case alreadyUnderway
        case other(Swift.Error)
        
        var localizedDescription: String {
            switch self {
            case .alreadyUnderway:
                return "Registration is already underway."
            case .other(let error):
                return "SDK Registration error: \(error.localizedDescription)"
            }
        }
    }
}

class DJIDroneSDK: NSObject, DroneSDK {
    var initializationStatus_ = CurrentValueSubject<Drone.InitializationStatus, Never>(.disconnected)
    var initializationStatus: AnyPublisher<Drone.InitializationStatus, Never> { self.initializationStatus_.eraseToAnyPublisher() }
    
    var componentState_ = PassthroughSubject<Drone.ComponentState, Never>()
    var componentState: AnyPublisher<Drone.ComponentState, Never> { self.componentState_.eraseToAnyPublisher() }
    
    var enableBridgeMode = true
    var bridgeAppIP: String? = nil
    var currentComponentState = Drone.ComponentState()
    
    private var completionHandler: CompletionHandler? = nil
    
    func initSDK(bridgeAppIP: String?, completionHandler handler: @escaping CompletionHandler) -> Void {
        guard !initializationStatus_.value.registrationUnderway() else {
            handler(.failure(Drone.Error.alreadyUnderway))
            return
        }
        
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        guard appKey != nil && appKey!.isEmpty == false else {
            NSLog("Please enter your app key in the info.plist")
            return
        }
                
        self.completionHandler = handler
        self.enableBridgeMode = bridgeAppIP != nil
        self.bridgeAppIP = bridgeAppIP
        self.initializationStatus_.send(.registering)

        DJISDKManager.registerApp(with: self)
    }
    
    func disconnect() {
        DJISDKManager.stopConnectionToProduct()
        DJISDKManager.stopListening(onProductConnectionUpdatesOfListener: self)
        DJISDKManager.stopListening(onComponentConnectionUpdatesOfListener: self)
        DJISDKManager.disableBridgeMode()
        self.initializationStatus_.send(.disconnected)
    }
    
    func startListeningForConnectionUpdates() {
        DJISDKManager.startListeningOnProductConnectionUpdates(withListener: self) { product in
            if let product = product, product.model != "Only RemoteController" {
                self.initializationStatus_.send(.connectedToAircraft)
            } else if case .connectedToAircraft = self.initializationStatus_.value {
                // aircraft was likely disconnected (vs. user called disconnect())
                self.initializationStatus_.send(.waitingForAircraft)
            }
        }
        
        DJISDKManager.startListeningOnComponentConnectionUpdates(withListener: self) { componentKey, index, isConnected in
            self.currentComponentState[componentKey]?.states[index] = Drone.ComponentState.State(isConnected)
            self.componentState_.send(self.currentComponentState)
            print((componentKey, index, isConnected))
        }
    }
    
    func execute(mission: Mission) {
        guard let djiMission = mission.asDJIWaypointMission() else {
            fatalError("TODO! handle failed mission conversion")
        }
        if let error = djiMission.checkParameters() {
            fatalError("TODO! handle error: \(error)")
        }
        
        guard let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator() else {
            fatalError("TODO! handle failed mission operator error")
        }
        if let loadError = missionOperator.load(djiMission) {
            fatalError("TODO! handle load error: \(loadError)")
        }
        
        guard case .readyToUpload = missionOperator.currentState else {
            fatalError("TODO! operator not in 'ready to upload' state: \(missionOperator.currentState)")
        }
        
        missionOperator.uploadMission { error in
            if let error = error {
                fatalError("TODO! error received during mission upload: \(error)")
            }
            
            guard case .readyToExecute = missionOperator.currentState else {
                fatalError("TODO! operator not in 'ready to execute' state: \(missionOperator.currentState)")
            }
            
//            // BE SURE ABOUT THIS!
//            missionOperator.startMission { _ in
//
//            }
        }
        
    }
}

extension DJIDroneSDK: DJISDKManagerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            self.initializationStatus_.send(.registrationFailed(error))
            self.completionHandler?(.failure(Drone.Error.other(error)))
            return
        }
        
        if let bridgeAppIP = bridgeAppIP {
            DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppIP)
        } else {
            // TODO handle direct connection
        }
        self.initializationStatus_.send(.waitingForAircraft)
        self.startListeningForConnectionUpdates()
        completionHandler?(.success(()))
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        // TODO
    }
}
