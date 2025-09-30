import Foundation
import GRDB

public struct AWRegion: Codable, FetchableRecord, PersistableRecord {
    public let id: Int64
    public let code: String
    public let localCode: String?
    public let name: String
    public let continent: String?
    public let isoCountry: String?
    public let wikipediaLink: String?
    public let keywords: String?
    
    // GRDB table name
    public static let databaseTableName = "regions"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case localCode = "local_code"
        case name
        case continent
        case isoCountry = "iso_country"
        case wikipediaLink = "wikipedia_link"
        case keywords
    }
    
    // Convenience initializer
    init(id: Int64, code: String, localCode: String? = nil, name: String, continent: String? = nil, isoCountry: String? = nil, wikipediaLink: String? = nil, keywords: String? = nil) {
        self.id = id
        self.code = code
        self.localCode = localCode
        self.name = name
        self.continent = continent
        self.isoCountry = isoCountry
        self.wikipediaLink = wikipediaLink
        self.keywords = keywords
    }
}

// MARK: - Equatable
extension AWRegion: Equatable {
    public static func == (lhs: AWRegion, rhs: AWRegion) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWRegion: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWRegion: CustomStringConvertible {
    public var description: String {
        return "Region(id: \(id), code: \(code), name: \(name))"
    }
}
