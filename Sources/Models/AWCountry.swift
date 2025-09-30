import Foundation
import GRDB

public struct AWCountry: Codable, FetchableRecord, PersistableRecord {
    public let id: Int64
    public let code: String
    public let name: String
    public let continent: String?
    public let wikipediaLink: String?
    public let keywords: String?
    
    // GRDB table name
    public static let databaseTableName = "countries"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case continent
        case wikipediaLink = "wikipedia_link"
        case keywords
    }
    
    // Initializer from GRDB Row
    public init(row: Row) throws {
        self.id = row["id"]
        self.code = row["code"]
        self.name = row["name"]
        self.continent = row["continent"]
        self.wikipediaLink = row["wikipedia_link"]
        self.keywords = row["keywords"]
    }
    
    // Convenience initializer for creating new countries
    init(
        id: Int64,
        code: String,
        name: String,
        continent: String? = nil,
        wikipediaLink: String? = nil,
        keywords: String? = nil
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.continent = continent
        self.wikipediaLink = wikipediaLink
        self.keywords = keywords
    }
}

// MARK: - Equatable
extension AWCountry: Equatable {
    public static func == (lhs: AWCountry, rhs: AWCountry) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWCountry: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWCountry: CustomStringConvertible {
    public var description: String {
        return "Country(id: \(id), code: \(code), name: \(name))"
    }
}
