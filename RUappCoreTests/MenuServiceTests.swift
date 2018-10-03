import XCTest
import CoreData
@testable import RUappCore

class MenuServiceTests: XCTestCase {

    func testUpdate() {
        let exp = expectation(description: "Update menu task")
        let url = Bundle(for: MenuServiceTests.self).url(forResource: "menu", withExtension: "json")!
        MenuService.updateMenu(request: URLRequest(url: url), context: PersistentContainer.test.newBackgroundContextForUpdate()) { (error) in
            XCTAssertNil(error)
            let req: NSFetchRequest<Meal> = Meal.fetchRequest()
            XCTAssertEqual(try! PersistentContainer.test.viewContext.count(for: req), 17)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
