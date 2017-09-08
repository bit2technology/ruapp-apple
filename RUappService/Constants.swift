
public let globalUserDefaults = UserDefaults(suiteName: "group.com.bit2software.RUapp")!

class ServiceURL {
    static let registerStudent = "https://www.ruapp.com.br/api/v1/register_student"
    static let sendVote = "https://www.ruapp.com.br/api/v1/vote"
    static let getInstitution = "https://www.ruapp.com.br/api/v1/institution"
    static let getInstitutionOverviewList = "https://www.ruapp.com.br/api/v1/institutions"
    static let getMenu = "https://www.ruapp.com.br/api/v1/menu"
}

public enum Result<T> {
    case success(value: T)
    case failure(error: Error)
}
