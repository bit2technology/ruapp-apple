import XCTest
import CoreData
@testable import RUappCore

class MenuServiceTests: XCTestCase {

    func testSuccessfulUpdate() {
        let exp = expectation(description: "Update menu task")
        let url = Bundle(for: MenuServiceTests.self).url(forResource: "Menu", withExtension: "json")!
        let context = PersistentContainer.forTesting().newBackgroundContextForUpdate()
        MenuService.updateMenu(request: URLRequest(url: url), context: context) { (error) in
            XCTAssertNil(error)
            let req: NSFetchRequest<Meal> = Meal.fetchRequest()
            XCTAssertEqual(try! context.count(for: req), 17)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testUnsuccessfulUpdate() {
        let exp = expectation(description: "Update menu task")
        let url = Bundle(for: MenuServiceTests.self).url(forResource: "MenuWithError", withExtension: "json")!
        let context = PersistentContainer.forTesting().newBackgroundContextForUpdate()
        MenuService.updateMenu(request: URLRequest(url: url), context: context) { (error) in
            XCTAssertNotNil(error)
            let req: NSFetchRequest<Meal> = Meal.fetchRequest()
            XCTAssertEqual(try! context.count(for: req), 0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testNotFoundUpdate() {
        let exp = expectation(description: "Update menu task")
        let url = Bundle(for: MenuServiceTests.self).bundleURL.appendingPathComponent("NotFound.json", isDirectory: false)
        let context = PersistentContainer.forTesting().newBackgroundContextForUpdate()
        MenuService.updateMenu(request: URLRequest(url: url), context: context) { (error) in
            XCTAssertNotNil(error)
            let req: NSFetchRequest<Meal> = Meal.fetchRequest()
            XCTAssertEqual(try! context.count(for: req), 0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
