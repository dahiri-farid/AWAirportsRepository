import Foundation
import SQLite

enum AWAirportType: String, CaseIterable {
    case smallAirport = "small_airport"
    case mediumAirport = "medium_airport"
    case largeAirport = "large_airport"
    case heliport = "heliport"
    case seaplaneBase = "seaplane_base"
    case balloonport = "balloonport"
    case closed = "closed"
    case other = "other"
}

enum AWScheduledService: String {
    case yes = "yes"
    case no = "no"
    case unknown = "unknown"
}

struct AWAirport {
    let id: Int64
    let ident: String
    let type: AWAirportType?
    let name: String?
    let latitudeDeg: Double?
    let longitudeDeg: Double?
    let elevationFt: Int?
    let continent: String?
    let isoCountry: String?
    let isoRegion: String?
    let municipality: String?
    let scheduledService: AWScheduledService?
    let icaoCode: String?
    let iataCode: String?
    let gpsCode: String?
    let localCode: String?
    let homeLink: String?
    let wikipediaLink: String?
    let keywords: String?
    
    // SQLite table definition
    static let table = Table("airports")
    static let id = Expression<Int64>("id")
    static let ident = Expression<String>("ident")
    static let type = Expression<String?>("type")
    static let name = Expression<String?>("name")
    static let latitudeDeg = Expression<Double?>("latitude_deg")
    static let longitudeDeg = Expression<Double?>("longitude_deg")
    static let elevationFt = Expression<Int?>("elevation_ft")
    static let continent = Expression<String?>("continent")
    static let isoCountry = Expression<String?>("iso_country")
    static let isoRegion = Expression<String?>("iso_region")
    static let municipality = Expression<String?>("municipality")
    static let scheduledService = Expression<String?>("scheduled_service")
    static let icaoCode = Expression<String?>("icao_code")
    static let iataCode = Expression<String?>("iata_code")
    static let gpsCode = Expression<String?>("gps_code")
    static let localCode = Expression<String?>("local_code")
    static let homeLink = Expression<String?>("home_link")
    static let wikipediaLink = Expression<String?>("wikipedia_link")
    static let keywords = Expression<String?>("keywords")
    
    // Initializer from database row
    init(row: Row) {
        self.id = row[AWAirport.id]
        self.ident = row[AWAirport.ident]
        self.type = row[AWAirport.type].flatMap(AWAirportType.init)
        self.name = row[AWAirport.name]
        self.latitudeDeg = row[AWAirport.latitudeDeg]
        self.longitudeDeg = row[AWAirport.longitudeDeg]
        self.elevationFt = row[AWAirport.elevationFt]
        self.continent = row[AWAirport.continent]
        self.isoCountry = row[AWAirport.isoCountry]
        self.isoRegion = row[AWAirport.isoRegion]
        self.municipality = row[AWAirport.municipality]
        self.scheduledService = row[AWAirport.scheduledService].flatMap(AWScheduledService.init)
        self.icaoCode = row[AWAirport.icaoCode]
        self.iataCode = row[AWAirport.iataCode]
        self.gpsCode = row[AWAirport.gpsCode]
        self.localCode = row[AWAirport.localCode]
        self.homeLink = row[AWAirport.homeLink]
        self.wikipediaLink = row[AWAirport.wikipediaLink]
        self.keywords = row[AWAirport.keywords]
    }
    
    // Convenience initializer
    init(
        id: Int64,
        ident: String,
        type: AWAirportType? = nil,
        name: String? = nil,
        latitudeDeg: Double? = nil,
        longitudeDeg: Double? = nil,
        elevationFt: Int? = nil,
        continent: String? = nil,
        isoCountry: String? = nil,
        isoRegion: String? = nil,
        municipality: String? = nil,
        scheduledService: AWScheduledService? = nil,
        icaoCode: String? = nil,
        iataCode: String? = nil,
        gpsCode: String? = nil,
        localCode: String? = nil,
        homeLink: String? = nil,
        wikipediaLink: String? = nil,
        keywords: String? = nil
    ) {
        self.id = id
        self.ident = ident
        self.type = type
        self.name = name
        self.latitudeDeg = latitudeDeg
        self.longitudeDeg = longitudeDeg
        self.elevationFt = elevationFt
        self.continent = continent
        self.isoCountry = isoCountry
        self.isoRegion = isoRegion
        self.municipality = municipality
        self.scheduledService = scheduledService
        self.icaoCode = icaoCode
        self.iataCode = iataCode
        self.gpsCode = gpsCode
        self.localCode = localCode
        self.homeLink = homeLink
        self.wikipediaLink = wikipediaLink
        self.keywords = keywords
    }
    
    // Computed properties for convenience
    var hasCoordinates: Bool {
        return latitudeDeg != nil && longitudeDeg != nil
    }
    
    var displayName: String {
        return name ?? ident
    }
    
    var primaryCode: String {
        return iataCode ?? icaoCode ?? ident
    }
}

// MARK: - Equatable
extension AWAirport: Equatable {
    static func == (lhs: AWAirport, rhs: AWAirport) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWAirport: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWAirport: CustomStringConvertible {
    var description: String {
        return "Airport(id: \(id), ident: \(ident), name: \(displayName))"
    }
}
