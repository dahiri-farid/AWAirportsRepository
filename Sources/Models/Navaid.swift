import Foundation
import SQLite

enum NavaidType: String, CaseIterable {
    case ndb = "NDB"
    case vor = "VOR"
    case dme = "DME"
    case tacan = "TACAN"
    case vorDme = "VOR-DME"
    case ndbDme = "NDB-DME"
    case loc = "LOC"
    case ils = "ILS"
    case gs = "GS"
    case outerMarker = "OM"
    case middleMarker = "MM"
    case innerMarker = "IM"
    case other = "other"
}

enum UsageType: String, CaseIterable {
    case both = "BOTH"
    case terminal = "TERMINAL"
    case low = "LO"
    case high = "HI"
    case other = "other"
}

enum Power: String, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case other = "other"
}

struct Navaid {
    let id: Int64
    let filename: String?
    let ident: String?
    let name: String?
    let type: NavaidType?
    let frequencyKhz: Int?
    let latitudeDeg: Double?
    let longitudeDeg: Double?
    let elevationFt: Int?
    let isoCountry: String?
    let dmeFrequencyKhz: Int?
    let dmeChannel: String?
    let dmeLatitudeDeg: Double?
    let dmeLongitudeDeg: Double?
    let dmeElevationFt: Int?
    let slavedVariationDeg: Double?
    let magneticVariationDeg: Double?
    let usageType: UsageType?
    let power: Power?
    let associatedAirport: String?
    
    // SQLite table definition
    static let table = Table("navaids")
    static let id = Expression<Int64>("id")
    static let filename = Expression<String?>("filename")
    static let ident = Expression<String?>("ident")
    static let name = Expression<String?>("name")
    static let type = Expression<String?>("type")
    static let frequencyKhz = Expression<Int?>("frequency_khz")
    static let latitudeDeg = Expression<Double?>("latitude_deg")
    static let longitudeDeg = Expression<Double?>("longitude_deg")
    static let elevationFt = Expression<Int?>("elevation_ft")
    static let isoCountry = Expression<String?>("iso_country")
    static let dmeFrequencyKhz = Expression<Int?>("dme_frequency_khz")
    static let dmeChannel = Expression<String?>("dme_channel")
    static let dmeLatitudeDeg = Expression<Double?>("dme_latitude_deg")
    static let dmeLongitudeDeg = Expression<Double?>("dme_longitude_deg")
    static let dmeElevationFt = Expression<Int?>("dme_elevation_ft")
    static let slavedVariationDeg = Expression<Double?>("slaved_variation_deg")
    static let magneticVariationDeg = Expression<Double?>("magnetic_variation_deg")
    static let usageType = Expression<String?>("usage_type")
    static let power = Expression<String?>("power")
    static let associatedAirport = Expression<String?>("associated_airport")
    
    // Initializer from database row
    init(row: Row) {
        self.id = row[Navaid.id]
        self.filename = row[Navaid.filename]
        self.ident = row[Navaid.ident]
        self.name = row[Navaid.name]
        self.type = row[Navaid.type].flatMap(NavaidType.init)
        self.frequencyKhz = row[Navaid.frequencyKhz]
        self.latitudeDeg = row[Navaid.latitudeDeg]
        self.longitudeDeg = row[Navaid.longitudeDeg]
        self.elevationFt = row[Navaid.elevationFt]
        self.isoCountry = row[Navaid.isoCountry]
        self.dmeFrequencyKhz = row[Navaid.dmeFrequencyKhz]
        self.dmeChannel = row[Navaid.dmeChannel]
        self.dmeLatitudeDeg = row[Navaid.dmeLatitudeDeg]
        self.dmeLongitudeDeg = row[Navaid.dmeLongitudeDeg]
        self.dmeElevationFt = row[Navaid.dmeElevationFt]
        self.slavedVariationDeg = row[Navaid.slavedVariationDeg]
        self.magneticVariationDeg = row[Navaid.magneticVariationDeg]
        self.usageType = row[Navaid.usageType].flatMap(UsageType.init)
        self.power = row[Navaid.power].flatMap(Power.init)
        self.associatedAirport = row[Navaid.associatedAirport]
    }
    
    // Convenience initializer
    init(id: Int64, filename: String? = nil, ident: String? = nil, name: String? = nil, type: NavaidType? = nil, frequencyKhz: Int? = nil, latitudeDeg: Double? = nil, longitudeDeg: Double? = nil, elevationFt: Int? = nil, isoCountry: String? = nil, dmeFrequencyKhz: Int? = nil, dmeChannel: String? = nil, dmeLatitudeDeg: Double? = nil, dmeLongitudeDeg: Double? = nil, dmeElevationFt: Int? = nil, slavedVariationDeg: Double? = nil, magneticVariationDeg: Double? = nil, usageType: UsageType? = nil, power: Power? = nil, associatedAirport: String? = nil) {
        self.id = id
        self.filename = filename
        self.ident = ident
        self.name = name
        self.type = type
        self.frequencyKhz = frequencyKhz
        self.latitudeDeg = latitudeDeg
        self.longitudeDeg = longitudeDeg
        self.elevationFt = elevationFt
        self.isoCountry = isoCountry
        self.dmeFrequencyKhz = dmeFrequencyKhz
        self.dmeChannel = dmeChannel
        self.dmeLatitudeDeg = dmeLatitudeDeg
        self.dmeLongitudeDeg = dmeLongitudeDeg
        self.dmeElevationFt = dmeElevationFt
        self.slavedVariationDeg = slavedVariationDeg
        self.magneticVariationDeg = magneticVariationDeg
        self.usageType = usageType
        self.power = power
        self.associatedAirport = associatedAirport
    }
    
    // Computed properties for convenience
    var frequencyMhz: Double? {
        guard let frequencyKhz = frequencyKhz else { return nil }
        return Double(frequencyKhz) / 1000.0
    }
    
    var dmeFrequencyMhz: Double? {
        guard let dmeFrequencyKhz = dmeFrequencyKhz else { return nil }
        return Double(dmeFrequencyKhz) / 1000.0
    }
    
    var displayName: String {
        return name ?? ident ?? "Unknown Navaid"
    }
}

// MARK: - Equatable
extension Navaid: Equatable {
    static func == (lhs: Navaid, rhs: Navaid) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Navaid: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension Navaid: CustomStringConvertible {
    var description: String {
        return "Navaid(id: \(id), ident: \(ident ?? "nil"), type: \(type?.rawValue ?? "nil"))"
    }
}
