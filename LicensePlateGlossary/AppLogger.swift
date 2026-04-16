//
//  AppLogger.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 16/04/2026.
//

import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static func logger(for category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
