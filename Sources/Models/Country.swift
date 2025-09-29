import Foundation
import SQLite

struct AWCountry {
    let id: Int64
    let code: String
    let name: String
    let continent: String?
    let wikipediaLink: String?
    let keywords: String?
    
    // SQLite table definition
    static let table = Table("countries")
    static let id = Expression<Int64>("id")
    static let code = Expression<String>("code")
    static let name = Expression<String>("name")
    static let continent = Expression<String?>("continent")
    static let wikipediaLink = Expression<String?>("wikipedia_link")
    static let keywords = Expression<String?>("keywords")
    
    // Initializer from database row
    init(row: Row) {
        self.id = row[AWCountry.id]
        self.code = row[AWCountry.code]
        self.name = row[AWCountry.name]
        self.continent = row[AWCountry.continent]
        self.wikipediaLink = row[AWCountry.wikipediaLink]
        self.keywords = row[AWCountry.keywords]
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
    static func == (lhs: AWCountry, rhs: AWCountry) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWCountry: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWCountry: CustomStringConvertible {
    var description: String {
        return "Country(id: \(id), code: \(code), name: \(name))"
    }
}
