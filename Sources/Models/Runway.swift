import Foundation
import SQLite

struct Runway {
    let id: Int64
    let airportRef: Int64
    let airportIdent: String?
    let lengthFt: Int?
    let widthFt: Int?
    let surface: String?
    let lighted: Bool?
    let closed: Bool?
    let leIdent: String?
    let leLatitudeDeg: Double?
    let leLongitudeDeg: Double?
    let leElevationFt: Int?
    let leHeadingDegT: Double?
    let leDisplacedThresholdFt: Int?
    let heIdent: String?
    let heLatitudeDeg: Double?
    let heLongitudeDeg: Double?
    let heElevationFt: Int?
    let heHeadingDegT: Double?
    let heDisplacedThresholdFt: Int?
    
    // SQLite table definition
    static let table = Table("runways")
    static let id = Expression<Int64>("id")
    static let airportRef = Expression<Int64>("airport_ref")
    static let airportIdent = Expression<String?>("airport_ident")
    static let lengthFt = Expression<Int?>("length_ft")
    static let widthFt = Expression<Int?>("width_ft")
    static let surface = Expression<String?>("surface")
    static let lighted = Expression<Int?>("lighted")
    static let closed = Expression<Int?>("closed")
    static let leIdent = Expression<String?>("le_ident")
    static let leLatitudeDeg = Expression<Double?>("le_latitude_deg")
    static let leLongitudeDeg = Expression<Double?>("le_longitude_deg")
    static let leElevationFt = Expression<Int?>("le_elevation_ft")
    static let leHeadingDegT = Expression<Double?>("le_heading_degT")
    static let leDisplacedThresholdFt = Expression<Int?>("le_displaced_threshold_ft")
    static let heIdent = Expression<String?>("he_ident")
    static let heLatitudeDeg = Expression<Double?>("he_latitude_deg")
    static let heLongitudeDeg = Expression<Double?>("he_longitude_deg")
    static let heElevationFt = Expression<Int?>("he_elevation_ft")
    static let heHeadingDegT = Expression<Double?>("he_heading_degT")
    static let heDisplacedThresholdFt = Expression<Int?>("he_displaced_threshold_ft")
    
    // Initializer from database row
    init(row: Row) {
        self.id = row[Runway.id]
        self.airportRef = row[Runway.airportRef]
        self.airportIdent = row[Runway.airportIdent]
        self.lengthFt = row[Runway.lengthFt]
        self.widthFt = row[Runway.widthFt]
        self.surface = row[Runway.surface]
        self.lighted = row[Runway.lighted].map { $0 == 1 }
        self.closed = row[Runway.closed].map { $0 == 1 }
        self.leIdent = row[Runway.leIdent]
        self.leLatitudeDeg = row[Runway.leLatitudeDeg]
        self.leLongitudeDeg = row[Runway.leLongitudeDeg]
        self.leElevationFt = row[Runway.leElevationFt]
        self.leHeadingDegT = row[Runway.leHeadingDegT]
        self.leDisplacedThresholdFt = row[Runway.leDisplacedThresholdFt]
        self.heIdent = row[Runway.heIdent]
        self.heLatitudeDeg = row[Runway.heLatitudeDeg]
        self.heLongitudeDeg = row[Runway.heLongitudeDeg]
        self.heElevationFt = row[Runway.heElevationFt]
        self.heHeadingDegT = row[Runway.heHeadingDegT]
        self.heDisplacedThresholdFt = row[Runway.heDisplacedThresholdFt]
    }
    
    // Convenience initializer
    init(id: Int64, airportRef: Int64, airportIdent: String? = nil, lengthFt: Int? = nil, widthFt: Int? = nil, surface: String? = nil, lighted: Bool? = nil, closed: Bool? = nil, leIdent: String? = nil, leLatitudeDeg: Double? = nil, leLongitudeDeg: Double? = nil, leElevationFt: Int? = nil, leHeadingDegT: Double? = nil, leDisplacedThresholdFt: Int? = nil, heIdent: String? = nil, heLatitudeDeg: Double? = nil, heLongitudeDeg: Double? = nil, heElevationFt: Int? = nil, heHeadingDegT: Double? = nil, heDisplacedThresholdFt: Int? = nil) {
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
extension Runway: Equatable {
    static func == (lhs: Runway, rhs: Runway) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Runway: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension Runway: CustomStringConvertible {
    var description: String {
        return "Runway(id: \(id), designation: \(runwayDesignation), length: \(lengthFt?.description ?? "nil") ft)"
    }
}
