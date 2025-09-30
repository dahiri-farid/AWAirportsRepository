import Foundation
import GRDB

public struct AWAirportFrequency: Codable, FetchableRecord, PersistableRecord {
    public let id: Int64
    public let airportRef: Int64
    public let airportIdent: String?
    public let type: String?
    public let details: String?
    public let frequencyMhz: Double?
    
    // GRDB table name
    public static let databaseTableName = "airport_frequencies"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case airportRef = "airport_ref"
        case airportIdent = "airport_ident"
        case type
        case details = "description"
        case frequencyMhz = "frequency_mhz"
    }
    
    // Convenience initializer
    init(
        id: Int64,
        airportRef: Int64,
        airportIdent: String? = nil,
        type: String? = nil,
        details: String? = nil,
        frequencyMhz: Double? = nil
    ) {
        self.id = id
        self.airportRef = airportRef
        self.airportIdent = airportIdent
        self.type = type
        self.details = details
        self.frequencyMhz = frequencyMhz
    }
}

// MARK: - Equatable
extension AWAirportFrequency: Equatable {
    public static func == (lhs: AWAirportFrequency, rhs: AWAirportFrequency) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWAirportFrequency: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomDebugStringConvertible
extension AWAirportFrequency: CustomStringConvertible {
    public var description: String {
        let freq = frequencyMhz.map { String($0) } ?? "nil"
        return "AirportFrequency(id: \(id), type: \(type ?? "nil"), frequency: \(freq) MHz)"
    }
}

