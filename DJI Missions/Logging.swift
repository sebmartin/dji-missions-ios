//
//  Logging.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-09.
//

import Foundation

import Logging

let LOGGING_PREFIX = "in.sebmart.DJIMissions"

extension Logger {
    init(suffix: String) {
        self.init(label: "\(LOGGING_PREFIX).\(suffix)")
    }
}
