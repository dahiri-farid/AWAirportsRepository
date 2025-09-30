import Foundation
import GRDB

public struct AWRunway: Codable, FetchableRecord, PersistableRecord {
    public let id: Int64
    public let airportRef: Int64
    public let airportIdent: String?
    public let lengthFt: Int?
    public let widthFt: Int?
    public let surface: String?
    public let lighted: Bool?
    public let closed: Bool?
    public let leIdent: String?
    public let leLatitudeDeg: Double?
    public let leLongitudeDeg: Double?
    public let leElevationFt: Int?
    public let leHeadingDegT: Double?
    public let leDisplacedThresholdFt: Int?
    public let heIdent: String?
    public let heLatitudeDeg: Double?
    public let heLongitudeDeg: Double?
    public let heElevationFt: Int?
    public let heHeadingDegT: Double?
    public let heDisplacedThresholdFt: Int?
    
    // GRDB table name
    public static let databaseTableName = "runways"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case airportRef = "airport_ref"
        case airportIdent = "airport_ident"
        case lengthFt = "length_ft"
        case widthFt = "width_ft"
        case surface
        case lighted
        case closed
        case leIdent = "le_ident"
        case leLatitudeDeg = "le_latitude_deg"
        case leLongitudeDeg = "le_longitude_deg"
        case leElevationFt = "le_elevation_ft"
        case leHeadingDegT = "le_heading_degT"
        case leDisplacedThresholdFt = "le_displaced_threshold_ft"
        case heIdent = "he_ident"
        case heLatitudeDeg = "he_latitude_deg"
        case heLongitudeDeg = "he_longitude_deg"
        case heElevationFt = "he_elevation_ft"
        case heHeadingDegT = "he_heading_degT"
        case heDisplacedThresholdFt = "he_displaced_threshold_ft"
    }
    
    // Convenience initializer
    init(
        id: Int64,
        airportRef: Int64,
        airportIdent: String? = nil,
        lengthFt: Int? = nil,
        widthFt: Int? = nil,
        surface: String? = nil,
        lighted: Bool? = nil,
        closed: Bool? = nil,
        leIdent: String? = nil,
        leLatitudeDeg: Double? = nil,
        leLongitudeDeg: Double? = nil,
        leElevationFt: Int? = nil,
        leHeadingDegT: Double? = nil,
        leDisplacedThresholdFt: Int? = nil,
        heIdent: String? = nil,
        heLatitudeDeg: Double? = nil,
        heLongitudeDeg: Double? = nil,
        heElevationFt: Int? = nil,
        heHeadingDegT: Double? = nil,
        heDisplacedThresholdFt: Int? = nil
    ) {
        self.id = id
        self.airportRef = airportRef
        self.airportIdent = airportIdent
        self.lengthFt = lengthFt
        self.widthFt = widthFt
        self.surface = surface
        self.lighted = lighted
        self.closed = closed
        self.leIdent = leIdent
        self.leLatitudeDeg = leLatitudeDeg
        self.leLongitudeDeg = leLongitudeDeg
        self.leElevationFt = leElevationFt
        self.leHeadingDegT = leHeadingDegT
        self.leDisplacedThresholdFt = leDisplacedThresholdFt
        self.heIdent = heIdent
        self.heLatitudeDeg = heLatitudeDeg
        self.heLongitudeDeg = heLongitudeDeg
        self.heElevationFt = heElevationFt
        self.heHeadingDegT = heHeadingDegT
        self.heDisplacedThresholdFt = heDisplacedThresholdFt
    }
    
    // Computed properties for convenience
    var lengthMeters: Double? {
        guard let lengthFt = lengthFt else { return nil }
        return Double(lengthFt) * 0.3048
    }
    
    var widthMeters: Double? {
        guard let widthFt = widthFt else { return nil }
        return Double(widthFt) * 0.3048
    }
    
    var runwayDesignation: String {
        let le = leIdent ?? "??"
        let he = heIdent ?? "??"
        return "\(le)/\(he)"
    }
}

// MARK: - Equatable
extension AWRunway: Equatable {
    public static func == (lhs: AWRunway, rhs: AWRunway) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWRunway: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWRunway: CustomStringConvertible {
    public var description: String {
        return "Runway(id: \(id), designation: \(runwayDesignation), length: \(lengthFt?.description ?? "nil") ft)"
    }
}
