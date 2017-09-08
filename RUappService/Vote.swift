
import Alamofire

open class Vote {
    
    open var item: Votable
    open var type: VoteType?
    open var reason: Set<Int>?
    open var comment: String?
    
    public init(item: Votable) {
        self.item = item
    }
    
    fileprivate func toRawDict() throws -> [String : Any] {
        // Verify values
        guard let type = type else {
            throw Error.noType
        }
        // Build dictionary
        var dict = ["dish_id": item.id, "vote_type_id": type.rawValue] as [String : Any]
        if let reason = reason, !reason.isEmpty {
            dict["pre_defined_comment_ids"] = Array(reason)
        }
        if let comment = comment {
            dict["comment"] = comment
        }
        // Return dictionary
        return dict
    }
    
    public enum VoteType: Int {
        case didntEat = 0
        case bad = 1
        case good = 2
        case veryGood = 3
    }
    
    enum Error: Swift.Error {
        case invalidInfo
        case noType
        case noData
    }
}

public extension Array where Element : Vote {
    
    public func send(completion: (Result<AnyObject>) -> Void) {
        do {
            guard let mealId = Menu.shared?.currentMeal?.id, let studentId = Student.shared?.id else {
                completion(.failure(error: Vote.Error.invalidInfo))
                return
            }
            
            let votesDict = try self.map { try $0.toRawDict() }
            
            var req = URLRequest(url: URL(string: ServiceURL.sendVote)!)
            req.httpMethod = "POST"
            let params = ["student_id": studentId, "meal_id": mealId, "votes": votesDict] as [String : Any]
            req.httpBody = params.appPrepare()
            Alamofire.request(req).responseJSON { (response) in
                print("vote completed success:", response.result.isSuccess, response.result.value)
            }
        } catch {
            completion(.failure(error: error))
            return
        }
    }
}
