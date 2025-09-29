import Foundation
import SQLite

struct AWRunway {
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
        self.id = row[AWRunway.id]
        self.airportRef = row[AWRunway.airportRef]
        self.airportIdent = row[AWRunway.airportIdent]
        self.lengthFt = row[AWRunway.lengthFt]
        self.widthFt = row[AWRunway.widthFt]
        self.surface = row[AWRunway.surface]
        self.lighted = row[AWRunway.lighted].map { $0 == 1 }
        self.closed = row[AWRunway.closed].map { $0 == 1 }
        self.leIdent = row[AWRunway.leIdent]
        self.leLatitudeDeg = row[AWRunway.leLatitudeDeg]
        self.leLongitudeDeg = row[AWRunway.leLongitudeDeg]
        self.leElevationFt = row[AWRunway.leElevationFt]
        self.leHeadingDegT = row[AWRunway.leHeadingDegT]
        self.leDisplacedThresholdFt = row[AWRunway.leDisplacedThresholdFt]
        self.heIdent = row[AWRunway.heIdent]
        self.heLatitudeDeg = row[AWRunway.heLatitudeDeg]
        self.heLongitudeDeg = row[AWRunway.heLongitudeDeg]
        self.heElevationFt = row[AWRunway.heElevationFt]
        self.heHeadingDegT = row[AWRunway.heHeadingDegT]
        self.heDisplacedThresholdFt = row[AWRunway.heDisplacedThresholdFt]
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
    static func == (lhs: AWRunway, rhs: AWRunway) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWRunway: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWRunway: CustomStringConvertible {
    var description: String {
        return "Runway(id: \(id), designation: \(runwayDesignation), length: \(lengthFt?.description ?? "nil") ft)"
    }
}
