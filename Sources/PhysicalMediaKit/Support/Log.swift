//
//  Log.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/6/26.
//

import OSLog

internal final class Log {
    private static let subsystem: String = "com.spencerhartland.PhysicalMediaKit"
    
    /// General logging.
    static let general = Logger(subsystem: subsystem, category: "general")
    /// Networking and API request logging.
    static let network = Logger(subsystem: subsystem, category: "network")
    /// View lifecycle and UI event logging.
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
