import Foundation
import SQLite

struct Region {
    let id: Int64
    let code: String
    let localCode: String?
    let name: String
    let continent: String?
    let isoCountry: String?
    let wikipediaLink: String?
    let keywords: String?
    
    // SQLite table definition
    static let table = Table("regions")
    static let id = Expression<Int64>("id")
    static let code = Expression<String>("code")
    static let localCode = Expression<String?>("local_code")
    static let name = Expression<String>("name")
    static let continent = Expression<String?>("continent")
    static let isoCountry = Expression<String?>("iso_country")
    static let wikipediaLink = Expression<String?>("wikipedia_link")
    static let keywords = Expression<String?>("keywords")
    
    // Initializer from database row
    init(row: Row) {
        self.id = row[Region.id]
        self.code = row[Region.code]
        self.localCode = row[Region.localCode]
        self.name = row[Region.name]
        self.continent = row[Region.continent]
        self.isoCountry = row[Region.isoCountry]
        self.wikipediaLink = row[Region.wikipediaLink]
        self.keywords = row[Region.keywords]
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
extension Region: Equatable {
    static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Region: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension Region: CustomStringConvertible {
    var description: String {
        return "Region(id: \(id), code: \(code), name: \(name))"
    }
}
