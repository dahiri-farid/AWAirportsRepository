import Foundation
import SQLite

enum AWNavaidType: String, CaseIterable {
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

enum AWUsageType: String, CaseIterable {
    case both = "BOTH"
    case terminal = "TERMINAL"
    case low = "LO"
    case high = "HI"
    case other = "other"
}

enum AWPower: String, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case other = "other"
}

struct AWNavaid {
    let id: Int64
    let filename: String?
    let ident: String?
    let name: String?
    let type: AWNavaidType?
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
    let usageType: AWUsageType?
    let power: AWPower?
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
        self.id = row[AWNavaid.id]
        self.filename = row[AWNavaid.filename]
        self.ident = row[AWNavaid.ident]
        self.name = row[AWNavaid.name]
        self.type = row[AWNavaid.type].flatMap(AWNavaidType.init)
        self.frequencyKhz = row[AWNavaid.frequencyKhz]
        self.latitudeDeg = row[AWNavaid.latitudeDeg]
        self.longitudeDeg = row[AWNavaid.longitudeDeg]
        self.elevationFt = row[AWNavaid.elevationFt]
        self.isoCountry = row[AWNavaid.isoCountry]
        self.dmeFrequencyKhz = row[AWNavaid.dmeFrequencyKhz]
        self.dmeChannel = row[AWNavaid.dmeChannel]
        self.dmeLatitudeDeg = row[AWNavaid.dmeLatitudeDeg]
        self.dmeLongitudeDeg = row[AWNavaid.dmeLongitudeDeg]
        self.dmeElevationFt = row[AWNavaid.dmeElevationFt]
        self.slavedVariationDeg = row[AWNavaid.slavedVariationDeg]
        self.magneticVariationDeg = row[AWNavaid.magneticVariationDeg]
        self.usageType = row[AWNavaid.usageType].flatMap(AWUsageType.init)
        self.power = row[AWNavaid.power].flatMap(AWPower.init)
        self.associatedAirport = row[AWNavaid.associatedAirport]
    }
    
    // Convenience initializer
    init(
        id: Int64,
        filename: String? = nil,
        ident: String? = nil,
        name: String? = nil,
        type: AWNavaidType? = nil,
        frequencyKhz: Int? = nil,
        latitudeDeg: Double? = nil,
        longitudeDeg: Double? = nil,
        elevationFt: Int? = nil,
        isoCountry: String? = nil,
        dmeFrequencyKhz: Int? = nil,
        dmeChannel: String? = nil,
        dmeLatitudeDeg: Double? = nil,
        dmeLongitudeDeg: Double? = nil,
        dmeElevationFt: Int? = nil,
        slavedVariationDeg: Double? = nil,
        magneticVariationDeg: Double? = nil,
        usageType: AWUsageType? = nil,
        power: AWPower? = nil,
        associatedAirport: String? = nil
    ) {
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
extension AWNavaid: Equatable {
    static func == (lhs: AWNavaid, rhs: AWNavaid) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWNavaid: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWNavaid: CustomStringConvertible {
    var description: String {
        return "Navaid(id: \(id), ident: \(ident ?? "nil"), type: \(type?.rawValue ?? "nil"))"
    }
}
