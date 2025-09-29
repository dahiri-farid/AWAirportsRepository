import Foundation
import SQLite

struct AWAirportFrequency {
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
        self.id = row[AWAirportFrequency.id]
        self.airportRef = row[AWAirportFrequency.airportRef]
        self.airportIdent = row[AWAirportFrequency.airportIdent]
        self.type = row[AWAirportFrequency.type]
        self.details = row[AWAirportFrequency.details]
        self.frequencyMhz = row[AWAirportFrequency.frequencyMhz]
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
    static func == (lhs: AWAirportFrequency, rhs: AWAirportFrequency) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWAirportFrequency: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomDebugStringConvertible
extension AWAirportFrequency: CustomStringConvertible {
    var description: String {
        let freq = frequencyMhz.map { String($0) } ?? "nil"
        return "AirportFrequency(id: \(id), type: \(type ?? "nil"), frequency: \(freq) MHz)"
    }
}

