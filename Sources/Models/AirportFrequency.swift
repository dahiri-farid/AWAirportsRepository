import Foundation
import SQLite

struct AirportFrequency {
    let id: Int64
    let airportRef: Int64
    let airportIdent: String?
    let type: String?
    let details: String?
    let frequencyMhz: Double?
    
    // SQLite table definition
    static let table = Table("airport_frequencies")
    static let id = Expression<Int64>("id")
    static let airportRef = Expression<Int64>("airport_ref")
    static let airportIdent = Expression<String?>("airport_ident")
    static let type = Expression<String?>("type")
    static let details = Expression<String?>("description")
    static let frequencyMhz = Expression<Double?>("frequency_mhz")
    
    // Initializer from database row
    init(row: Row) {
        self.id = row[AirportFrequency.id]
        self.airportRef = row[AirportFrequency.airportRef]
        self.airportIdent = row[AirportFrequency.airportIdent]
        self.type = row[AirportFrequency.type]
        self.details = row[AirportFrequency.details]
        self.frequencyMhz = row[AirportFrequency.frequencyMhz]
    }
    
    // Convenience initializer
    init(id: Int64, airportRef: Int64, airportIdent: String? = nil, type: String? = nil, details: String? = nil, frequencyMhz: Double? = nil) {
        self.id = id
        self.airportRef = airportRef
        self.airportIdent = airportIdent
        self.type = type
        self.details = details
        self.frequencyMhz = frequencyMhz
    }
}

// MARK: - Equatable
extension AirportFrequency: Equatable {
    static func == (lhs: AirportFrequency, rhs: AirportFrequency) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AirportFrequency: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomDebugStringConvertible
extension AirportFrequency: CustomStringConvertible {
    var description: String {
        let freq = frequencyMhz.map { String($0) } ?? "nil"
        return "AirportFrequency(id: \(id), type: \(type ?? "nil"), frequency: \(freq) MHz)"
    }
}

