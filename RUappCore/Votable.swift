import Foundation

public final class Votable: NSObject {
    public var name = ""
    public var meta = ""
    public var id: Int64 = 0
}

extension Votable: Decodable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        meta = try container.decode(String.self, forKey: .meta)
        id = try container.decode(Int64.self, forKey: .id)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case meta
        case id
    }
}

extension Votable: NSSecureCoding {
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
        aCoder.encode(meta, forKey: CodingKeys.meta.rawValue)
        aCoder.encode(id, forKey: CodingKeys.id.rawValue)
    }
    
    public convenience init?(coder aDecoder: NSCoder) {
        self.init()
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue)! as String
        meta = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.meta.rawValue)! as String
        id = aDecoder.decodeInt64(forKey: CodingKeys.id.rawValue)
    }
}
