import Foundation
import GRDB

public enum AWNavaidType: String, CaseIterable, Codable {
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

public enum AWUsageType: String, CaseIterable, Codable {
    case both = "BOTH"
    case terminal = "TERMINAL"
    case low = "LO"
    case high = "HI"
    case other = "other"
}

public enum AWPower: String, CaseIterable, Codable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case other = "other"
}

public struct AWNavaid: Codable, FetchableRecord, PersistableRecord {
    public let id: Int64
    public let filename: String?
    public let ident: String?
    public let name: String?
    public let type: AWNavaidType?
    public let frequencyKhz: Int?
    public let latitudeDeg: Double?
    public let longitudeDeg: Double?
    public let elevationFt: Int?
    public let isoCountry: String?
    public let dmeFrequencyKhz: Int?
    public let dmeChannel: String?
    public let dmeLatitudeDeg: Double?
    public let dmeLongitudeDeg: Double?
    public let dmeElevationFt: Int?
    public let slavedVariationDeg: Double?
    public let magneticVariationDeg: Double?
    public let usageType: AWUsageType?
    public let power: AWPower?
    public let associatedAirport: String?
    
    // GRDB table name
    public static let databaseTableName = "navaids"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case filename
        case ident
        case name
        case type
        case frequencyKhz = "frequency_khz"
        case latitudeDeg = "latitude_deg"
        case longitudeDeg = "longitude_deg"
        case elevationFt = "elevation_ft"
        case isoCountry = "iso_country"
        case dmeFrequencyKhz = "dme_frequency_khz"
        case dmeChannel = "dme_channel"
        case dmeLatitudeDeg = "dme_latitude_deg"
        case dmeLongitudeDeg = "dme_longitude_deg"
        case dmeElevationFt = "dme_elevation_ft"
        case slavedVariationDeg = "slaved_variation_deg"
        case magneticVariationDeg = "magnetic_variation_deg"
        case usageType = "usage_type"
        case power
        case associatedAirport = "associated_airport"
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
    public static func == (lhs: AWNavaid, rhs: AWNavaid) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWNavaid: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWNavaid: CustomStringConvertible {
    public var description: String {
        return "Navaid(id: \(id), ident: \(ident ?? "nil"), type: \(type?.rawValue ?? "nil"))"
    }
}
