import Foundation
import SQLite

struct AWAirportComment {
    let id: Int64
    let threadRef: Int64?
    let airportRef: Int64?
    let airportIdent: String?
    let date: String?
    let memberNickname: String?
    let subject: String?
    let body: String?
    
    // SQLite table definition
    static let table = Table("airport_comments")
    static let id = Expression<Int64>("id")
    static let threadRef = Expression<Int64?>("thread_ref")
    static let airportRef = Expression<Int64?>("airport_ref")
    static let airportIdent = Expression<String?>("airport_ident")
    static let date = Expression<String?>("date")
    static let memberNickname = Expression<String?>("member_nickname")
    static let subject = Expression<String?>("subject")
    static let body = Expression<String?>("body")
    
    // Initializer from database row
    init(row: Row) {
        self.id = row[AWAirportComment.id]
        self.threadRef = row[AWAirportComment.threadRef]
        self.airportRef = row[AWAirportComment.airportRef]
        self.airportIdent = row[AWAirportComment.airportIdent]
        self.date = row[AWAirportComment.date]
        self.memberNickname = row[AWAirportComment.memberNickname]
        self.subject = row[AWAirportComment.subject]
        self.body = row[AWAirportComment.body]
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
    static func == (lhs: AWAirportComment, rhs: AWAirportComment) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AWAirportComment: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible
extension AWAirportComment: CustomStringConvertible {
    var description: String {
        return "AirportComment(id: \(id), subject: \(displaySubject), author: \(memberNickname ?? "anonymous"))"
    }
}
