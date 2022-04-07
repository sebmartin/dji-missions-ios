//
//  ProductCommunicationManager.swift
//  SDK Swift Sample
//
//  Created by Arnaud Thiercelin on 3/22/17.
//  Copyright © 2017 DJI. All rights reserved.
//

import UIKit
import DJISDK
import Combine

protocol DroneSDK {
    typealias CompletionHandler = (Result<Void, DroneRegistration.Error>) -> Void
    
    var status: AnyPublisher<DroneRegistration.Status, Never> { get }

    func initSDK(bridgeAppIP: String?, completionHandler handler: @escaping CompletionHandler) -> Void
}

struct DroneRegistration {
    enum Status: CustomStringConvertible {
        case notStarted
        case registering
        case registered
        case registrationFailed(Swift.Error)
        
        var description: String {
            switch self {
            case .notStarted: return "Not started"
            case .registering: return "Registering"
            case .registered: return "Registration complete"
            case .registrationFailed: return "Registration failed"
            }
        }
        
        func registrationUnderway() -> Bool {
            if case .registering = self {
                return true
            }
            return false
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
    var status_ = CurrentValueSubject<DroneRegistration.Status, Never>(.notStarted)
    var status: AnyPublisher<DroneRegistration.Status, Never> { self.status_.eraseToAnyPublisher() }
    
    
    var enableBridgeMode = true
    var bridgeAppIP = ""
    
    private var completionHandler: CompletionHandler? = nil
    
    func initSDK(bridgeAppIP: String?, completionHandler handler: @escaping CompletionHandler) -> Void {
        guard !status_.value.registrationUnderway() else {
            handler(.failure(DroneRegistration.Error.alreadyUnderway))
            return
        }
        
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        guard appKey != nil && appKey!.isEmpty == false else {
            NSLog("Please enter your app key in the info.plist")
            return
        }
        
        self.completionHandler = handler
        self.enableBridgeMode = bridgeAppIP != nil
        self.bridgeAppIP = bridgeAppIP ?? ""
        self.status_.send(.registering)
        DJISDKManager.registerApp(with: self)
    }
}

extension DJIDroneSDK: DJISDKManagerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            self.status_.send(.registrationFailed(error))
            self.completionHandler?(.failure(DroneRegistration.Error.other(error)))
            return
        }
        self.status_.send(.registered)
        
        DJISDKManager.enableBridgeMode(withBridgeAppIP: self.bridgeAppIP)
        self.completionHandler?(.success(()))
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        // TODO
    }
}
