import Foundation
import GRDB

public struct AWAirportComment: Codable, FetchableRecord, PersistableRecord {
    public let id: Int64
    public let threadRef: Int64?
    public let airportRef: Int64?
    public let airportIdent: String?
    public let date: String?
    public let memberNickname: String?
    public let subject: String?
    public let body: String?
    
    // GRDB table name
    public static let databaseTableName = "airport_comments"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case threadRef = "thread_ref"
        case airportRef = "airport_ref"
        case airportIdent = "airport_ident"
        case date
        case memberNickname = "member_nickname"
        case subject
        case body
    }
    
    // Convenience initializer
    init(
        id: Int64,
        threadRef: Int64? = nil,
        airportRef: Int64? = nil,
        airportIdent: String? = nil,
        date: String? = nil,
        memberNickname: String? = nil,
        subject: String? = nil,
        body: String? = nil
    ) {
        self.id = id
        self.threadRef = threadRef
        self.airportRef = airportRef
        self.airportIdent = airportIdent
        self.date = date
        self.memberNickname = memberNickname
        self.subject = subject
        self.body = body
    }
    
    // Computed properties for convenience
    var displaySubject: String {
        return subject ?? "(no subject)"
    }
    
    var displayDate: Date? {
        guard let dateString = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: dateString)
    }
    
    var formattedDate: String? {
        guard let date = displayDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Equatable
extension AWAirportComment: Equatable {
    public static func == (lhs: AWAirportComment, rhs: AWAirportComment) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWAirportComment: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWAirportComment: CustomStringConvertible {
    public var description: String {
        return "AirportComment(id: \(id), subject: \(displaySubject), author: \(memberNickname ?? "anonymous"))"
    }
}
