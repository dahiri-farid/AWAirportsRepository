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
    
    func getAllCountries() throws -> [Country] {
        return try db.prepare(Country.table).map { Country(row: $0) }
    }
    
    func getCountry(by code: String) throws -> Country? {
        let query = Country.table.filter(Country.code == code)
        return try db.pluck(query).map { Country(row: $0) }
    }
    
    func getCountries(by continent: String) throws -> [Country] {
        let query = Country.table.filter(Country.continent == continent)
        return try db.prepare(query).map { Country(row: $0) }
    }
    
    // MARK: - Regions
    
    func getAllRegions() throws -> [Region] {
        return try db.prepare(Region.table).map { Region(row: $0) }
    }
    
    func getRegions(by countryCode: String) throws -> [Region] {
        let query = Region.table.filter(Region.isoCountry == countryCode)
        return try db.prepare(query).map { Region(row: $0) }
    }
    
    func getRegion(by code: String) throws -> Region? {
        let query = Region.table.filter(Region.code == code)
        return try db.pluck(query).map { Region(row: $0) }
    }
    
    // MARK: - Airports
    
    func getAllAirports() throws -> [Airport] {
        return try db.prepare(Airport.table).map { Airport(row: $0) }
    }
    
    func getAirport(id: Int64) throws -> Airport? {
        let query = Airport.table.filter(Airport.id == id)
        return try db.pluck(query).map { Airport(row: $0) }
    }
    
    func getAirport(ident: String) throws -> Airport? {
        let query = Airport.table.filter(Airport.ident == ident)
        return try db.pluck(query).map { Airport(row: $0) }
    }
    
    func getAirport(iataCode: String) throws -> Airport? {
        let query = Airport.table.filter(Airport.iataCode == iataCode)
        return try db.pluck(query).map { Airport(row: $0) }
    }
    
    func getAirport(icaoCode: String) throws -> Airport? {
        let query = Airport.table.filter(Airport.icaoCode == icaoCode)
        return try db.pluck(query).map { Airport(row: $0) }
    }
    
    func getAirports(countryCode: String) throws -> [Airport] {
        let query = Airport.table.filter(Airport.isoCountry == countryCode)
        return try db.prepare(query).map { Airport(row: $0) }
    }
    
    func getAirports(regionCode: String) throws -> [Airport] {
        let query = Airport.table.filter(Airport.isoRegion == regionCode)
        return try db.prepare(query).map { Airport(row: $0) }
    }
    
    func getAirports(type: AirportType) throws -> [Airport] {
        let query = Airport.table.filter(Airport.type == type.rawValue)
        return try db.prepare(query).map { Airport(row: $0) }
    }
    
    func searchAirports(name: String) throws -> [Airport] {
        let query = Airport.table.filter(Airport.name.like("%\(name)%"))
        return try db.prepare(query).map { Airport(row: $0) }
    }
    
    func getAirportsNear(latitude: Double, longitude: Double, radiusKm: Double = 50) throws -> [Airport] {
        let latDelta = radiusKm / 111.0
        let lonDelta = radiusKm / (111.0 * abs(latitude) / 90.0)
        
        let query = Airport.table
            .filter(Airport.latitudeDeg >= latitude - latDelta)
            .filter(Airport.latitudeDeg <= latitude + latDelta)
            .filter(Airport.longitudeDeg >= longitude - lonDelta)
            .filter(Airport.longitudeDeg <= longitude + lonDelta)
            .filter(Airport.latitudeDeg != nil)
            .filter(Airport.longitudeDeg != nil)
        
        return try db.prepare(query).map { Airport(row: $0) }
    }
    
    /// Returns the single nearest airport to the given coordinate within the specified search radius.
    /// - Parameters:
    ///   - latitude: The latitude of the reference point in degrees.
    ///   - longitude: The longitude of the reference point in degrees.
    ///   - radiusKm: The search radius in kilometers (defaults to 50km). If no airports are found in this radius, returns nil.
    /// - Returns: The nearest `Airport` if one exists in the search radius; otherwise `nil`.
    func getNearestAirport(latitude: Double, longitude: Double, radiusKm: Double = 50) throws -> Airport? {
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
        let nearest = candidates.compactMap { airport -> (Airport, Double)? in
            guard let lat = airport.latitudeDeg, let lon = airport.longitudeDeg else { return nil }
            let distance = haversineDistanceKm(latitude, longitude, lat, lon)
            return (airport, distance)
        }.min(by: { $0.1 < $1.1 })?.0

        return nearest
    }
    
    func getAirportsForLocation(latitude: Double, longitude: Double, rangeLatitude: Double, rangeLongitude: Double) throws -> [Airport] {
        let query = Airport.table
            .filter(Airport.longitudeDeg >= longitude - rangeLongitude)
            .filter(Airport.longitudeDeg <= longitude + rangeLongitude)
            .filter(Airport.latitudeDeg >= latitude - rangeLatitude)
            .filter(Airport.latitudeDeg <= latitude + rangeLatitude)
            .filter(Airport.latitudeDeg != nil)
            .filter(Airport.longitudeDeg != nil)
        
        return try db.prepare(query).map { Airport(row: $0) }
    }
    
    func getAirportsForLocation(latitude: Double, longitude: Double, rangeInDegrees: Double) throws -> [Airport] {
        return try getAirportsForLocation(
            latitude: latitude,
            longitude: longitude,
            rangeLatitude: rangeInDegrees,
            rangeLongitude: rangeInDegrees
        )
    }
    
    // MARK: - Airport Frequencies
    
    func getFrequencies(for airportId: Int64) throws -> [AirportFrequency] {
        let query = AirportFrequency.table.filter(AirportFrequency.airportRef == airportId)
        return try db.prepare(query).map { AirportFrequency(row: $0) }
    }
    
    func getFrequencies(for airportIdent: String) throws -> [AirportFrequency] {
        let query = AirportFrequency.table.filter(AirportFrequency.airportIdent == airportIdent)
        return try db.prepare(query).map { AirportFrequency(row: $0) }
    }
    
    func getFrequencies(by type: String) throws -> [AirportFrequency] {
        let query = AirportFrequency.table.filter(AirportFrequency.type == type)
        return try db.prepare(query).map { AirportFrequency(row: $0) }
    }
    
    // MARK: - Runways
    
    func getRunways(for airportId: Int64) throws -> [Runway] {
        let query = Runway.table.filter(Runway.airportRef == airportId)
        return try db.prepare(query).map { Runway(row: $0) }
    }
    
    func getRunways(for airportIdent: String) throws -> [Runway] {
        let query = Runway.table.filter(Runway.airportIdent == airportIdent)
        return try db.prepare(query).map { Runway(row: $0) }
    }
    
    func getRunways(longerThan lengthFt: Int) throws -> [Runway] {
        let query = Runway.table.filter(Runway.lengthFt >= lengthFt)
        return try db.prepare(query).map { Runway(row: $0) }
    }
    
    func getRunways(with surface: String) throws -> [Runway] {
        let query = Runway.table.filter(Runway.surface.like("%\(surface)%"))
        return try db.prepare(query).map { Runway(row: $0) }
    }
    
    // MARK: - Navaids
    
    func getAllNavaids() throws -> [Navaid] {
        return try db.prepare(Navaid.table).map { Navaid(row: $0) }
    }
    
    func getNavaids(by countryCode: String) throws -> [Navaid] {
        let query = Navaid.table.filter(Navaid.isoCountry == countryCode)
        return try db.prepare(query).map { Navaid(row: $0) }
    }
    
    func getNavaids(by type: NavaidType) throws -> [Navaid] {
        let query = Navaid.table.filter(Navaid.type == type.rawValue)
        return try db.prepare(query).map { Navaid(row: $0) }
    }
    
    func getNavaids(for airportIdent: String) throws -> [Navaid] {
        let query = Navaid.table.filter(Navaid.associatedAirport == airportIdent)
        return try db.prepare(query).map { Navaid(row: $0) }
    }
    
    func searchNavaids(by name: String) throws -> [Navaid] {
        let query = Navaid.table.filter(Navaid.name.like("%\(name)%"))
        return try db.prepare(query).map { Navaid(row: $0) }
    }
    
    // MARK: - Airport Comments
    
    func getComments(for airportId: Int64) throws -> [AirportComment] {
        let query = AirportComment.table.filter(AirportComment.airportRef == airportId)
        return try db.prepare(query).map { AirportComment(row: $0) }
    }
    
    func getComments(for airportIdent: String) throws -> [AirportComment] {
        let query = AirportComment.table.filter(AirportComment.airportIdent == airportIdent)
        return try db.prepare(query).map { AirportComment(row: $0) }
    }
    
    func getRecentComments(limit: Int = 50) throws -> [AirportComment] {
        let query = AirportComment.table.order(AirportComment.date.desc).limit(limit)
        return try db.prepare(query).map { AirportComment(row: $0) }
    }
    
    // MARK: - Complex Queries
    
    func getAirportWithDetails(by ident: String) throws -> (airport: Airport, country: Country?, region: Region?, frequencies: [AirportFrequency], runways: [Runway], navaids: [Navaid], comments: [AirportComment])? {
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
        let countries = try db.scalar(Country.table.count)
        let regions = try db.scalar(Region.table.count)
        let airports = try db.scalar(Airport.table.count)
        let frequencies = try db.scalar(AirportFrequency.table.count)
        let runways = try db.scalar(Runway.table.count)
        let navaids = try db.scalar(Navaid.table.count)
        let comments = try db.scalar(AirportComment.table.count)
        
        return (countries: countries, regions: regions, airports: airports, frequencies: frequencies, runways: runways, navaids: navaids, comments: comments)
    }
    
    func getTopCountriesByAirportCount(limit: Int = 10) throws -> [(country: Country, count: Int)] {
        let query = Airport.table
            .join(Country.table, on: Airport.isoCountry == Country.code)
            .group(Country.code)
            .select(Country.table[*], Airport.id.count)
            .order(Airport.id.count.desc)
            .limit(limit)
        
        return try db.prepare(query).map { row in
            let country = Country(row: row)
            let count = row[Airport.id.count]
            return (country: country, count: count)
        }
    }
    
    func getAirportTypesDistribution() throws -> [(type: AirportType?, count: Int)] {
        let query = Airport.table
            .group(Airport.type)
            .select(Airport.type, Airport.id.count)
            .order(Airport.id.count.desc)
        
        return try db.prepare(query).map { row in
            let typeString = row[Airport.type]
            let type = typeString.flatMap(AirportType.init)
            let count = row[Airport.id.count]
            return (type: type, count: count)
        }
    }
}
