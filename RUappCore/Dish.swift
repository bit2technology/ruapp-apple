import Foundation

public final class Dish: NSObject {
    public var type = ""
    public var meta = ""
    public var name: String?
}

extension Dish: Decodable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        meta = try container.decode(String.self, forKey: .meta)
        name = try? container.decode(String.self, forKey: .name)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case meta
        case name
    }
}

extension Dish: NSSecureCoding {
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        aCoder.encode(meta, forKey: CodingKeys.meta.rawValue)
        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
    }
    
    public convenience init?(coder aDecoder: NSCoder) {
        self.init()
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue)! as String
        meta = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.meta.rawValue)! as String
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as String?
    }
}
