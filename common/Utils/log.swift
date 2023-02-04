//
//  Log.swfit
//  metal-tutorial
//
//  Created by user on 2023/01/22.
//

import OSLog

extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let debug = OSLog(subsystem: subsystem, category: "Debug")
    static let info = OSLog(subsystem: subsystem, category: "Info")
    static let error = OSLog(subsystem: subsystem, category: "Error")
    static let fault = OSLog(subsystem: subsystem, category: "Fault")

    static let mouse = OSLog(subsystem: subsystem, category: "Mouse")
    static let key = OSLog(subsystem: subsystem, category: "Key")
    static let camera = OSLog(subsystem: subsystem, category: "Camera")
}
