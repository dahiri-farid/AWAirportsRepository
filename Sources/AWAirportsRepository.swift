import Foundation
import SQLite

class AWAirportsRepository {
    private let db: Connection
    
    // MARK: - Initialization
    
    init(databasePath: String) throws {
        self.db = try Connection(databasePath)
    }
    
    convenience init() throws {
        // Default to the database in the same directory as this file
        let currentDirectory = FileManager.default.currentDirectoryPath
        let databasePath = "\(currentDirectory)/ourairports.db"
        try self.init(databasePath: databasePath)
    }
    
    // MARK: - Countries
    
    func getAllCountries() throws -> [AWCountry] {
        return try db.prepare(AWCountry.table).map { AWCountry(row: $0) }
    }
    
    func getCountry(by code: String) throws -> AWCountry? {
        let query = AWCountry.table.filter(AWCountry.code == code)
        return try db.pluck(query).map { AWCountry(row: $0) }
    }
    
    func getCountries(by continent: String) throws -> [AWCountry] {
        let query = AWCountry.table.filter(AWCountry.continent == continent)
        return try db.prepare(query).map { AWCountry(row: $0) }
    }
    
    // MARK: - Regions
    
    func getAllRegions() throws -> [AWRegion] {
        return try db.prepare(AWRegion.table).map { AWRegion(row: $0) }
    }
    
    func getRegions(by countryCode: String) throws -> [AWRegion] {
        let query = AWRegion.table.filter(AWRegion.isoCountry == countryCode)
        return try db.prepare(query).map { AWRegion(row: $0) }
    }
    
    func getRegion(by code: String) throws -> AWRegion? {
        let query = AWRegion.table.filter(AWRegion.code == code)
        return try db.pluck(query).map { AWRegion(row: $0) }
    }
    
    // MARK: - Airports
    
    func getAllAirports() throws -> [AWAirport] {
        return try db.prepare(AWAirport.table).map { AWAirport(row: $0) }
    }
    
    func getAirport(id: Int64) throws -> AWAirport? {
        let query = AWAirport.table.filter(AWAirport.id == id)
        return try db.pluck(query).map { AWAirport(row: $0) }
    }
    
    func getAirport(ident: String) throws -> AWAirport? {
        let query = AWAirport.table.filter(AWAirport.ident == ident)
        return try db.pluck(query).map { AWAirport(row: $0) }
    }
    
    func getAirport(iataCode: String) throws -> AWAirport? {
        let query = AWAirport.table.filter(AWAirport.iataCode == iataCode)
        return try db.pluck(query).map { AWAirport(row: $0) }
    }
    
    func getAirport(icaoCode: String) throws -> AWAirport? {
        let query = AWAirport.table.filter(AWAirport.icaoCode == icaoCode)
        return try db.pluck(query).map { AWAirport(row: $0) }
    }
    
    func getAirports(countryCode: String) throws -> [AWAirport] {
        let query = AWAirport.table.filter(AWAirport.isoCountry == countryCode)
        return try db.prepare(query).map { AWAirport(row: $0) }
    }
    
    func getAirports(regionCode: String) throws -> [AWAirport] {
        let query = AWAirport.table.filter(AWAirport.isoRegion == regionCode)
        return try db.prepare(query).map { AWAirport(row: $0) }
    }
    
    func getAirports(type: AWAirportType) throws -> [AWAirport] {
        let query = AWAirport.table.filter(AWAirport.type == type.rawValue)
        return try db.prepare(query).map { AWAirport(row: $0) }
    }
    
    func searchAirports(name: String) throws -> [AWAirport] {
        let query = AWAirport.table.filter(AWAirport.name.like("%\(name)%"))
        return try db.prepare(query).map { AWAirport(row: $0) }
    }
    
    func getAirportsNear(latitude: Double, longitude: Double, radiusKm: Double = 50) throws -> [AWAirport] {
        let latDelta = radiusKm / 111.0
        let lonDelta = radiusKm / (111.0 * abs(latitude) / 90.0)
        
        let query = AWAirport.table
            .filter(AWAirport.latitudeDeg >= latitude - latDelta)
            .filter(AWAirport.latitudeDeg <= latitude + latDelta)
            .filter(AWAirport.longitudeDeg >= longitude - lonDelta)
            .filter(AWAirport.longitudeDeg <= longitude + lonDelta)
            .filter(AWAirport.latitudeDeg != nil)
            .filter(AWAirport.longitudeDeg != nil)
        
        return try db.prepare(query).map { AWAirport(row: $0) }
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
        let query = AWAirport.table
            .filter(AWAirport.longitudeDeg >= longitude - rangeLongitude)
            .filter(AWAirport.longitudeDeg <= longitude + rangeLongitude)
            .filter(AWAirport.latitudeDeg >= latitude - rangeLatitude)
            .filter(AWAirport.latitudeDeg <= latitude + rangeLatitude)
            .filter(AWAirport.latitudeDeg != nil)
            .filter(AWAirport.longitudeDeg != nil)
        
        return try db.prepare(query).map { AWAirport(row: $0) }
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
        let query = AWAirportFrequency.table.filter(AWAirportFrequency.airportRef == airportId)
        return try db.prepare(query).map { AWAirportFrequency(row: $0) }
    }
    
    func getFrequencies(for airportIdent: String) throws -> [AWAirportFrequency] {
        let query = AWAirportFrequency.table.filter(AWAirportFrequency.airportIdent == airportIdent)
        return try db.prepare(query).map { AWAirportFrequency(row: $0) }
    }
    
    func getFrequencies(by type: String) throws -> [AWAirportFrequency] {
        let query = AWAirportFrequency.table.filter(AWAirportFrequency.type == type)
        return try db.prepare(query).map { AWAirportFrequency(row: $0) }
    }
    
    // MARK: - Runways
    
    func getRunways(for airportId: Int64) throws -> [AWRunway] {
        let query = AWRunway.table.filter(AWRunway.airportRef == airportId)
        return try db.prepare(query).map { AWRunway(row: $0) }
    }
    
    func getRunways(for airportIdent: String) throws -> [AWRunway] {
        let query = AWRunway.table.filter(AWRunway.airportIdent == airportIdent)
        return try db.prepare(query).map { AWRunway(row: $0) }
    }
    
    func getRunways(longerThan lengthFt: Int) throws -> [AWRunway] {
        let query = AWRunway.table.filter(AWRunway.lengthFt >= lengthFt)
        return try db.prepare(query).map { AWRunway(row: $0) }
    }
    
    func getRunways(with surface: String) throws -> [AWRunway] {
        let query = AWRunway.table.filter(AWRunway.surface.like("%\(surface)%"))
        return try db.prepare(query).map { AWRunway(row: $0) }
    }
    
    // MARK: - Navaids
    
    func getAllNavaids() throws -> [AWNavaid] {
        return try db.prepare(AWNavaid.table).map { AWNavaid(row: $0) }
    }
    
    func getNavaids(by countryCode: String) throws -> [AWNavaid] {
        let query = AWNavaid.table.filter(AWNavaid.isoCountry == countryCode)
        return try db.prepare(query).map { AWNavaid(row: $0) }
    }
    
    func getNavaids(by type: AWNavaidType) throws -> [AWNavaid] {
        let query = AWNavaid.table.filter(AWNavaid.type == type.rawValue)
        return try db.prepare(query).map { AWNavaid(row: $0) }
    }
    
    func getNavaids(for airportIdent: String) throws -> [AWNavaid] {
        let query = AWNavaid.table.filter(AWNavaid.associatedAirport == airportIdent)
        return try db.prepare(query).map { AWNavaid(row: $0) }
    }
    
    func searchNavaids(by name: String) throws -> [AWNavaid] {
        let query = AWNavaid.table.filter(AWNavaid.name.like("%\(name)%"))
        return try db.prepare(query).map { AWNavaid(row: $0) }
    }
    
    // MARK: - Airport Comments
    
    func getComments(for airportId: Int64) throws -> [AWAirportComment] {
        let query = AWAirportComment.table.filter(AWAirportComment.airportRef == airportId)
        return try db.prepare(query).map { AWAirportComment(row: $0) }
    }
    
    func getComments(for airportIdent: String) throws -> [AWAirportComment] {
        let query = AWAirportComment.table.filter(AWAirportComment.airportIdent == airportIdent)
        return try db.prepare(query).map { AWAirportComment(row: $0) }
    }
    
    func getRecentComments(limit: Int = 50) throws -> [AWAirportComment] {
        let query = AWAirportComment.table.order(AWAirportComment.date.desc).limit(limit)
        return try db.prepare(query).map { AWAirportComment(row: $0) }
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
        let countries = try db.scalar(AWCountry.table.count)
        let regions = try db.scalar(AWRegion.table.count)
        let airports = try db.scalar(AWAirport.table.count)
        let frequencies = try db.scalar(AWAirportFrequency.table.count)
        let runways = try db.scalar(AWRunway.table.count)
        let navaids = try db.scalar(AWNavaid.table.count)
        let comments = try db.scalar(AWAirportComment.table.count)
        
        return (countries: countries, regions: regions, airports: airports, frequencies: frequencies, runways: runways, navaids: navaids, comments: comments)
    }
    
    func getTopCountriesByAirportCount(limit: Int = 10) throws -> [(country: AWCountry, count: Int)] {
        let query = AWAirport.table
            .join(AWCountry.table, on: AWAirport.isoCountry == AWCountry.code)
            .group(AWCountry.code)
            .select(AWCountry.table[*], AWAirport.id.count)
            .order(AWAirport.id.count.desc)
            .limit(limit)
        
        return try db.prepare(query).map { row in
            let country = AWCountry(row: row)
            let count = row[AWAirport.id.count]
            return (country: country, count: count)
        }
    }
    
    func getAirportTypesDistribution() throws -> [(type: AWAirportType?, count: Int)] {
        let query = AWAirport.table
            .group(AWAirport.type)
            .select(AWAirport.type, AWAirport.id.count)
            .order(AWAirport.id.count.desc)
        
        return try db.prepare(query).map { row in
            let typeString = row[AWAirport.type]
            let type = typeString.flatMap(AWAirportType.init)
            let count = row[AWAirport.id.count]
            return (type: type, count: count)
        }
    }
}
