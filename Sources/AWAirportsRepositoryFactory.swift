//
//  File.swift
//  AWAirportsRepository
//
//  Created by Farid Dahiri on 29.09.2025.
//

import Foundation

public final class AWAirportsRepositoryFactory {
    public static func make(databasePath: String) throws -> AWAirportsRepository {
        try AWAirportsRepositoryImpl(databasePath: databasePath)
    }
}
