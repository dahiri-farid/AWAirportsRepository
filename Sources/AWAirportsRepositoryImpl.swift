//
//  File.swift
//  AWAirportsRepositoryImpl
//
//  Created by Farid Dahiri on 29.09.2025.
//

import Foundation
import GRDB

final class AWAirportsRepositoryImpl: AWAirportsRepository {
    private let db: DatabaseWriter
    
    // MARK: - Initialization
    
    init(databasePath: String) throws {
        self.db = try DatabaseQueue(path: databasePath)
    }
    
    // MARK: - Countries
    
    func getAllCountries() throws -> [AWCountry] {
        return try db.read { db in
            try AWCountry.fetchAll(db)
        }
    }
    
    func getCountry(by code: String) throws -> AWCountry? {
        return try db.read { db in
            try AWCountry.filter(Column("code") == code).fetchOne(db)
        }
    }
    
    func getCountries(by continent: String) throws -> [AWCountry] {
        return try db.read { db in
            try AWCountry.filter(Column("continent") == continent).fetchAll(db)
        }
    }
    
    // MARK: - Regions
    
    func getAllRegions() throws -> [AWRegion] {
        return try db.read { db in
            try AWRegion.fetchAll(db)
        }
    }
    
    func getRegions(by countryCode: String) throws -> [AWRegion] {
        return try db.read { db in
            try AWRegion.filter(Column("iso_country") == countryCode).fetchAll(db)
        }
    }
    
    func getRegion(by code: String) throws -> AWRegion? {
        return try db.read { db in
            try AWRegion.filter(Column("code") == code).fetchOne(db)
        }
    }
    
    // MARK: - Airports
    
    /// Helper method to filter airports by valid ICAO codes
    private func filterByValidICAO(_ airports: [AWAirport], onlyValidICAO: Bool) -> [AWAirport] {
        guard onlyValidICAO else { return airports }
        return airports.filter { airport in
            return airport.ident.trimmingCharacters(in: .whitespacesAndNewlines).count == 4
        }
    }
    
    func getAllAirports(onlyValidICAO: Bool) throws -> [AWAirport] {
        let airports = try db.read { db in
            try AWAirport.fetchAll(db)
        }
        return filterByValidICAO(airports, onlyValidICAO: onlyValidICAO)
    }
    
    func getAirport(id: Int64) throws -> AWAirport? {
        return try db.read { db in
            try AWAirport.filter(Column("id") == id).fetchOne(db)
        }
    }
    
    func getAirport(ident: String) throws -> AWAirport? {
        return try db.read { db in
            try AWAirport.filter(Column("ident") == ident).fetchOne(db)
        }
    }
    
    func getAirport(iataCode: String) throws -> AWAirport? {
        return try db.read { db in
            try AWAirport.filter(Column("iata_code") == iataCode).fetchOne(db)
        }
    }
    
    func getAirport(icaoCode: String) throws -> AWAirport? {
        return try db.read { db in
            try AWAirport.filter(Column("icao_code") == icaoCode).fetchOne(db)
        }
    }
    
    func getAirports(countryCode: String, onlyValidICAO: Bool) throws -> [AWAirport] {
        let airports = try db.read { db in
            try AWAirport.filter(Column("iso_country") == countryCode).fetchAll(db)
        }
        return filterByValidICAO(airports, onlyValidICAO: onlyValidICAO)
    }
    
    func getAirports(regionCode: String, onlyValidICAO: Bool) throws -> [AWAirport] {
        let airports = try db.read { db in
            try AWAirport.filter(Column("iso_region") == regionCode).fetchAll(db)
        }
        return filterByValidICAO(airports, onlyValidICAO: onlyValidICAO)
    }
    
    func getAirports(type: AWAirportType, onlyValidICAO: Bool) throws -> [AWAirport] {
        let airports = try db.read { db in
            try AWAirport.filter(Column("type") == type.rawValue).fetchAll(db)
        }
        return filterByValidICAO(airports, onlyValidICAO: onlyValidICAO)
    }
    
    func searchAirports(name: String, onlyValidICAO: Bool) throws -> [AWAirport] {
        let airports = try db.read { db in
            try AWAirport.filter(Column("name").like("%\(name)%")).fetchAll(db)
        }
        return filterByValidICAO(airports, onlyValidICAO: onlyValidICAO)
    }
    
    func getAirportsNear(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 50,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> [AWAirport] {
        let latDelta = radiusKm / 111.0
        let lonDelta = radiusKm / (111.0 * abs(latitude) / 90.0)
        
        // Use the existing getAirportsForLocation method which works correctly
        return try getAirportsForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: latDelta,
            rangeLongitude: lonDelta,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
    }
    
    /// Returns the single nearest airport to the given coordinate within the specified search radius.
    /// - Parameters:
    ///   - latitude: The latitude of the reference point in degrees.
    ///   - longitude: The longitude of the reference point in degrees.
    ///   - radiusKm: The search radius in kilometers (defaults to 50km). If no airports are found in this radius, returns nil.
    /// - Returns: The nearest `Airport` if one exists in the search radius; otherwise `nil`.
    func getNearestAirport(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 50,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> AWAirport? {
        // Local Haversine distance calculator (in kilometers)
        func haversineDistanceKm(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
            let R = 6371.0 // Earth's mean radius in km
            let φ1 = lat1 * .pi / 180
            let φ2 = lat2 * .pi / 180
            let Δφ = (lat2 - lat1) * .pi / 180
            let Δλ = (lon2 - lon1) * .pi / 180
            let a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)
            let c = 2 * atan2(sqrt(a), sqrt(1 - a))
            return R * c
        }
        
        // First, get candidate airports in a bounding box around the coordinate.
        let candidates = try getAirportsNear(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
        guard !candidates.isEmpty else { return nil }
        
        // Compute precise distances and return the closest one.
        let nearest = candidates.compactMap { airport -> (AWAirport, Double)? in
            guard let lat = airport.latitudeDeg, let lon = airport.longitudeDeg else { return nil }
            let distance = haversineDistanceKm(latitude, longitude, lat, lon)
            return (airport, distance)
        }.min(by: { $0.1 < $1.1 })?.0
        
        return nearest
    }
    
    func getAirportsForLocation(
        latitude: Double,
        longitude: Double,
        rangeLatitude: Double,
        rangeLongitude: Double,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> [AWAirport] {
        // Compute bounding box
        let minLon = longitude - rangeLongitude
        let maxLon = longitude + rangeLongitude
        let minLat = latitude - rangeLatitude
        let maxLat = latitude + rangeLatitude

        let airports = try db.read { db in
            try AWAirport
                .filter(Column("latitude_deg") != nil && Column("longitude_deg") != nil)
                .filter(Column("longitude_deg") >= minLon && Column("longitude_deg") <= maxLon)
                .filter(Column("latitude_deg") >= minLat && Column("latitude_deg") <= maxLat)
                .filter(types.contains(Column("type")))
                .fetchAll(db)
        }
        return filterByValidICAO(airports, onlyValidICAO: onlyValidICAO)
    }
    
    func getAirportsForLocation(
        latitude: Double,
        longitude: Double,
        rangeInDegrees: Double,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> [AWAirport] {
        return try getAirportsForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: rangeInDegrees,
            rangeLongitude: rangeInDegrees,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
    }
    
    // MARK: - Airport Frequencies
    
    func getFrequencies(for airportId: Int64) throws -> [AWAirportFrequency] {
        return try db.read { db in
            try AWAirportFrequency.filter(Column("airport_ref") == airportId).fetchAll(db)
        }
    }
    
    func getFrequencies(for airportIdent: String) throws -> [AWAirportFrequency] {
        return try db.read { db in
            try AWAirportFrequency.filter(Column("airport_ident") == airportIdent).fetchAll(db)
        }
    }
    
    func getFrequencies(by type: String) throws -> [AWAirportFrequency] {
        return try db.read { db in
            try AWAirportFrequency.filter(Column("type") == type).fetchAll(db)
        }
    }
    
    // MARK: - Runways
    
    func getRunways(for airportId: Int64) throws -> [AWRunway] {
        return try db.read { db in
            try AWRunway.filter(Column("airport_ref") == airportId).fetchAll(db)
        }
    }
    
    func getRunways(for airportIdent: String) throws -> [AWRunway] {
        return try db.read { db in
            try AWRunway.filter(Column("airport_ident") == airportIdent).fetchAll(db)
        }
    }
    
    func getRunways(longerThan lengthFt: Int) throws -> [AWRunway] {
        return try db.read { db in
            try AWRunway.filter(Column("length_ft") >= lengthFt).fetchAll(db)
        }
    }
    
    func getRunways(with surface: String) throws -> [AWRunway] {
        return try db.read { db in
            try AWRunway.filter(Column("surface").like("%\(surface)%")).fetchAll(db)
        }
    }
    
    // MARK: - Navaids
    
    func getAllNavaids() throws -> [AWNavaid] {
        return try db.read { db in
            try AWNavaid.fetchAll(db)
        }
    }
    
    func getNavaids(by countryCode: String) throws -> [AWNavaid] {
        return try db.read { db in
            try AWNavaid.filter(Column("iso_country") == countryCode).fetchAll(db)
        }
    }
    
    func getNavaids(by type: AWNavaidType) throws -> [AWNavaid] {
        return try db.read { db in
            try AWNavaid.filter(Column("type") == type.rawValue).fetchAll(db)
        }
    }
    
    func getNavaids(for airportIdent: String) throws -> [AWNavaid] {
        return try db.read { db in
            try AWNavaid.filter(Column("associated_airport") == airportIdent).fetchAll(db)
        }
    }
    
    func searchNavaids(by name: String) throws -> [AWNavaid] {
        return try db.read { db in
            try AWNavaid.filter(Column("name").like("%\(name)%")).fetchAll(db)
        }
    }
    
    // MARK: - Complex Queries
    
    func getAirportWithDetails(by ident: String) throws -> (airport: AWAirport, country: AWCountry?, region: AWRegion?, frequencies: [AWAirportFrequency], runways: [AWRunway], navaids: [AWNavaid])? {
        guard let airport = try getAirport(ident: ident) else { return nil }
        
        let country = airport.isoCountry.flatMap { try? getCountry(by: $0) }
        let region = airport.isoRegion.flatMap { try? getRegion(by: $0) }
        let frequencies = try getFrequencies(for: airport.id)
        let runways = try getRunways(for: airport.id)
        let navaids = try getNavaids(for: airport.ident)
        
        return (airport: airport, country: country, region: region, frequencies: frequencies, runways: runways, navaids: navaids)
    }
    
    func getStatistics() throws -> (countries: Int, regions: Int, airports: Int, frequencies: Int, runways: Int, navaids: Int) {
        return try db.read { db in
            let countries = try AWCountry.fetchCount(db)
            let regions = try AWRegion.fetchCount(db)
            let airports = try AWAirport.fetchCount(db)
            let frequencies = try AWAirportFrequency.fetchCount(db)
            let runways = try AWRunway.fetchCount(db)
            let navaids = try AWNavaid.fetchCount(db)
            
            return (countries: countries, regions: regions, airports: airports, frequencies: frequencies, runways: runways, navaids: navaids)
        }
    }
    
    func getTopCountriesByAirportCount(limit: Int = 10) throws -> [(country: AWCountry, count: Int)] {
        return try db.read { db in
            let sql = """
                SELECT c.*, COUNT(a.id) as airport_count
                FROM countries c
                JOIN airports a ON c.code = a.iso_country
                GROUP BY c.code
                ORDER BY airport_count DESC
                LIMIT ?
            """
            return try Row.fetchAll(db, sql: sql, arguments: [limit]).map { row in
                let country = try AWCountry(row: row)
                let count = row["airport_count"] as Int
                return (country: country, count: count)
            }
        }
    }
    
    func getAirportTypesDistribution() throws -> [(type: AWAirportType?, count: Int)] {
        return try db.read { db in
            let sql = """
                SELECT type, COUNT(id) as count
                FROM airports
                GROUP BY type
                ORDER BY count DESC
            """
            return try Row.fetchAll(db, sql: sql).map { row in
                let typeString = row["type"] as String?
                let type = typeString.flatMap(AWAirportType.init)
                let count = row["count"] as Int
                return (type: type, count: count)
            }
        }
    }

    // MARK: - Airports with Runways
    func getAirportWithRunways(id: Int64) throws -> (airport: AWAirport, runways: [AWRunway])? {
        return try db.read { db in
            guard let airport = try AWAirport.filter(Column("id") == id).fetchOne(db) else { return nil }
            let runways = try AWRunway.filter(Column("airport_ref") == id).fetchAll(db)
            return (airport: airport, runways: runways)
        }
    }

    func getAirportWithRunways(ident: String) throws -> (airport: AWAirport, runways: [AWRunway])? {
        guard let airport = try getAirport(ident: ident) else { return nil }
        let runways = try getRunways(for: ident)
        return (airport: airport, runways: runways)
    }

    func getAirportsWithRunways(countryCode: String, onlyValidICAO: Bool) throws -> [(airport: AWAirport, runways: [AWRunway])] {
        return try db.read { db in
            var airports = try AWAirport.filter(Column("iso_country") == countryCode).fetchAll(db)
            airports = filterByValidICAO(airports, onlyValidICAO: onlyValidICAO)
            if airports.isEmpty { return [] }
            let airportIds = airports.map { $0.id }
            let runways = try AWRunway.filter(airportIds.contains(Column("airport_ref"))).fetchAll(db)
            let runwaysByAirport = Dictionary(grouping: runways, by: { $0.airportRef })
            return airports.map { ($0, runwaysByAirport[$0.id] ?? []) }
        }
    }
    
    func getAirportsWithRunwaysNear(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 50,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> [(airport: AWAirport, runways: [AWRunway])] {
        let airports = try getAirportsNear(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
        if airports.isEmpty { return [] }
        
        return try db.read { db in
            let airportIds = airports.map { $0.id }
            let runways = try AWRunway.filter(airportIds.contains(Column("airport_ref"))).fetchAll(db)
            let runwaysByAirport = Dictionary(grouping: runways, by: { $0.airportRef })
            return airports.map { ($0, runwaysByAirport[$0.id] ?? []) }
        }
    }
    
    func getNearestAirportWithRunways(
        latitude: Double,
        longitude: Double,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> (airport: AWAirport, runways: [AWRunway])? {
        // Use a default radius of 200km for broad search
        return try getNearestAirportWithRunways(
            latitude: latitude,
            longitude: longitude,
            radiusKm: 200,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
    }
    
    func getNearestAirportWithRunways(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> (airport: AWAirport, runways: [AWRunway])? {
        guard let airport = try getNearestAirport(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
            types: types,
            onlyValidICAO: onlyValidICAO
        ) else {
            return nil
        }
        
        return try db.read { db in
            let runways = try AWRunway.filter(Column("airport_ref") == airport.id).fetchAll(db)
            return (airport: airport, runways: runways)
        }
    }
    
    func getNearestAirportWithRunways(
        latitude: Double,
        longitude: Double,
        rangeLatitude: Double,
        rangeLongitude: Double,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> (airport: AWAirport, runways: [AWRunway])? {
        // Local Haversine distance calculator (in kilometers)
        func haversineDistanceKm(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
            let R = 6371.0 // Earth's mean radius in km
            let φ1 = lat1 * .pi / 180
            let φ2 = lat2 * .pi / 180
            let Δφ = (lat2 - lat1) * .pi / 180
            let Δλ = (lon2 - lon1) * .pi / 180
            let a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)
            let c = 2 * atan2(sqrt(a), sqrt(1 - a))
            return R * c
        }
        
        // Get candidate airports in the bounding box
        let candidates = try getAirportsForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: rangeLatitude,
            rangeLongitude: rangeLongitude,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
        guard !candidates.isEmpty else { return nil }
        
        // Find the nearest airport by computing precise distances
        let nearest = candidates.compactMap { airport -> (AWAirport, Double)? in
            guard let lat = airport.latitudeDeg, let lon = airport.longitudeDeg else { return nil }
            let distance = haversineDistanceKm(latitude, longitude, lat, lon)
            return (airport, distance)
        }.min(by: { $0.1 < $1.1 })?.0
        
        guard let airport = nearest else { return nil }
        
        return try db.read { db in
            let runways = try AWRunway.filter(Column("airport_ref") == airport.id).fetchAll(db)
            return (airport: airport, runways: runways)
        }
    }
    
    func getAirportsWithRunwaysForLocation(
        latitude: Double,
        longitude: Double,
        rangeLatitude: Double,
        rangeLongitude: Double,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> [(airport: AWAirport, runways: [AWRunway])] {
        let airports = try getAirportsForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: rangeLatitude,
            rangeLongitude: rangeLongitude,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
        if airports.isEmpty { return [] }
        
        return try db.read { db in
            let airportIds = airports.map { $0.id }
            let runways = try AWRunway.filter(airportIds.contains(Column("airport_ref"))).fetchAll(db)
            let runwaysByAirport = Dictionary(grouping: runways, by: { $0.airportRef })
            return airports.map { ($0, runwaysByAirport[$0.id] ?? []) }
        }
    }
    
    func getAirportsWithRunwaysForLocation(
        latitude: Double,
        longitude: Double,
        rangeInDegrees: Double,
        types: [String],
        onlyValidICAO: Bool
    ) throws -> [(airport: AWAirport, runways: [AWRunway])] {
        return try getAirportsWithRunwaysForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: rangeInDegrees,
            rangeLongitude: rangeInDegrees,
            types: types,
            onlyValidICAO: onlyValidICAO
        )
    }
}
