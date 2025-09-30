import Foundation
import GRDB

public enum AWAirportType: String, CaseIterable, Codable {
    case smallAirport = "small_airport"
    case mediumAirport = "medium_airport"
    case largeAirport = "large_airport"
    case heliport = "heliport"
    case seaplaneBase = "seaplane_base"
    case balloonport = "balloonport"
    case closed = "closed"
    case other = "other"
}

public enum AWScheduledService: String, Codable {
    case yes = "yes"
    case no = "no"
    case unknown = "unknown"
}

public struct AWAirport: Codable, FetchableRecord, PersistableRecord {
    public let id: Int64
    public let ident: String
    public let type: AWAirportType?
    public let name: String?
    public let latitudeDeg: Double?
    public let longitudeDeg: Double?
    public let elevationFt: Int?
    public let continent: String?
    public let isoCountry: String?
    public let isoRegion: String?
    public let municipality: String?
    public let scheduledService: AWScheduledService?
    public let icaoCode: String?
    public let iataCode: String?
    public let gpsCode: String?
    public let localCode: String?
    public let homeLink: String?
    public let wikipediaLink: String?
    public let keywords: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case ident
        case type
        case name
        case latitudeDeg = "latitude_deg"
        case longitudeDeg = "longitude_deg"
        case elevationFt = "elevation_ft"
        case continent
        case isoCountry = "iso_country"
        case isoRegion = "iso_region"
        case municipality
        case scheduledService = "scheduled_service"
        case icaoCode = "icao_code"
        case iataCode = "iata_code"
        case gpsCode = "gps_code"
        case localCode = "local_code"
        case homeLink = "home_link"
        case wikipediaLink = "wikipedia_link"
        case keywords
    }
    
    // GRDB table name
    public static let databaseTableName = "airports"
    
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
    public var hasCoordinates: Bool {
        return latitudeDeg != nil && longitudeDeg != nil
    }
    
    public var displayName: String {
        return name ?? ident
    }
    
    public var primaryCode: String {
        return iataCode ?? icaoCode ?? ident
    }
}

// MARK: - Equatable
extension AWAirport: Equatable {
    public static func == (lhs: AWAirport, rhs: AWAirport) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWAirport: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWAirport: CustomStringConvertible {
    public var description: String {
        return "Airport(id: \(id), ident: \(ident), name: \(displayName))"
    }
}
