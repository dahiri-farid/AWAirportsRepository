import Foundation
import SQLite

struct AWRegion {
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
        self.id = row[AWRegion.id]
        self.code = row[AWRegion.code]
        self.localCode = row[AWRegion.localCode]
        self.name = row[AWRegion.name]
        self.continent = row[AWRegion.continent]
        self.isoCountry = row[AWRegion.isoCountry]
        self.wikipediaLink = row[AWRegion.wikipediaLink]
        self.keywords = row[AWRegion.keywords]
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
    static func == (lhs: AWRegion, rhs: AWRegion) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWRegion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWRegion: CustomStringConvertible {
    var description: String {
        return "Region(id: \(id), code: \(code), name: \(name))"
    }
}
