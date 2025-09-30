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
    
    func getAllAirports() throws -> [AWAirport] {
        return try db.read { db in
            try AWAirport.fetchAll(db)
        }
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
    
    func getAirports(countryCode: String) throws -> [AWAirport] {
        return try db.read { db in
            try AWAirport.filter(Column("iso_country") == countryCode).fetchAll(db)
        }
    }
    
    func getAirports(regionCode: String) throws -> [AWAirport] {
        return try db.read { db in
            try AWAirport.filter(Column("iso_region") == regionCode).fetchAll(db)
        }
    }
    
    func getAirports(type: AWAirportType) throws -> [AWAirport] {
        return try db.read { db in
            try AWAirport.filter(Column("type") == type.rawValue).fetchAll(db)
        }
    }
    
    func searchAirports(name: String) throws -> [AWAirport] {
        return try db.read { db in
            try AWAirport.filter(Column("name").like("%\(name)%")).fetchAll(db)
        }
    }
    
    func getAirportsNear(latitude: Double, longitude: Double, radiusKm: Double = 50) throws -> [AWAirport] {
        let latDelta = radiusKm / 111.0
        let lonDelta = radiusKm / (111.0 * abs(latitude) / 90.0)
        
        // Use the existing getAirportsForLocation method which works correctly
        return try getAirportsForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: latDelta,
            rangeLongitude: lonDelta
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
        radiusKm: Double = 50
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
        let candidates = try getAirportsNear(latitude: latitude, longitude: longitude, radiusKm: radiusKm)
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
        rangeLongitude: Double
    ) throws -> [AWAirport] {
        // Compute bounding box
        let minLon = longitude - rangeLongitude
        let maxLon = longitude + rangeLongitude
        let minLat = latitude - rangeLatitude
        let maxLat = latitude + rangeLatitude

        return try db.read { db in
            try AWAirport
                .filter(Column("latitude_deg") != nil && Column("longitude_deg") != nil)
                .filter(Column("longitude_deg") >= minLon && Column("longitude_deg") <= maxLon)
                .filter(Column("latitude_deg") >= minLat && Column("latitude_deg") <= maxLat)
                .fetchAll(db)
        }
    }
    
    func getAirportsForLocation(latitude: Double, longitude: Double, rangeInDegrees: Double) throws -> [AWAirport] {
        return try getAirportsForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: rangeInDegrees,
            rangeLongitude: rangeInDegrees
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
    
    // MARK: - Airport Comments
    
    func getComments(for airportId: Int64) throws -> [AWAirportComment] {
        return try db.read { db in
            try AWAirportComment.filter(Column("airport_ref") == airportId).fetchAll(db)
        }
    }
    
    func getComments(for airportIdent: String) throws -> [AWAirportComment] {
        return try db.read { db in
            try AWAirportComment.filter(Column("airport_ident") == airportIdent).fetchAll(db)
        }
    }
    
    func getRecentComments(limit: Int = 50) throws -> [AWAirportComment] {
        return try db.read { db in
            try AWAirportComment.order(Column("date").desc).limit(limit).fetchAll(db)
        }
    }
    
    // MARK: - Complex Queries
    
    func getAirportWithDetails(by ident: String) throws -> (airport: AWAirport, country: AWCountry?, region: AWRegion?, frequencies: [AWAirportFrequency], runways: [AWRunway], navaids: [AWNavaid], comments: [AWAirportComment])? {
        guard let airport = try getAirport(ident: ident) else { return nil }
        
        let country = airport.isoCountry.flatMap { try? getCountry(by: $0) }
        let region = airport.isoRegion.flatMap { try? getRegion(by: $0) }
        let frequencies = try getFrequencies(for: airport.id)
        let runways = try getRunways(for: airport.id)
        let navaids = try getNavaids(for: airport.ident)
        let comments = try getComments(for: airport.id)
        
        return (airport: airport, country: country, region: region, frequencies: frequencies, runways: runways, navaids: navaids, comments: comments)
    }
    
    func getStatistics() throws -> (countries: Int, regions: Int, airports: Int, frequencies: Int, runways: Int, navaids: Int, comments: Int) {
        return try db.read { db in
            let countries = try AWCountry.fetchCount(db)
            let regions = try AWRegion.fetchCount(db)
            let airports = try AWAirport.fetchCount(db)
            let frequencies = try AWAirportFrequency.fetchCount(db)
            let runways = try AWRunway.fetchCount(db)
            let navaids = try AWNavaid.fetchCount(db)
            let comments = try AWAirportComment.fetchCount(db)
            
            return (countries: countries, regions: regions, airports: airports, frequencies: frequencies, runways: runways, navaids: navaids, comments: comments)
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
}
