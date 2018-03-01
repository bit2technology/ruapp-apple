//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData
import PromiseKit

@objc(Cafeteria)
public class Cafeteria: NSManagedObject, Decodable {

  public class func `default`(from userDefaults: UserDefaults = .shared, in context: NSManagedObjectContext = PersistentContainer.shared.viewContext) -> Cafeteria? {
    guard let cafeteriaID = userDefaults.value(forKey: "DefaultCafeteriaID") as? Int64 else {
      return nil
    }
    let request: NSFetchRequest<Cafeteria> = fetchRequest()
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "id = %lld", cafeteriaID)
    let result = try? context.fetch(request)
    return result?.first
  }

  public func setDefault(at userDefaults: UserDefaults = .shared) {
    userDefaults.set(id, forKey: "DefaultCafeteriaID")
  }

  public func nextMeal(for date: Date = Date(), in context: NSManagedObjectContext = PersistentContainer.shared.viewContext) -> Meal? {
      let request: NSFetchRequest<Meal> = Meal.fetchRequest()
      request.predicate = NSPredicate(format: "cafeteria = %@ AND close > %@", self, date as NSDate)
      request.sortDescriptors = [NSSortDescriptor(key: "close", ascending: true)]
      request.fetchLimit = 1
      return (try? context.fetch(request))?.first
  }

  public convenience init(context: NSManagedObjectContext) {
    self.init(entity: NSEntityDescription.entity(forEntityName: "Cafeteria", in: context)!, insertInto: context)
  }

  public required convenience init(from decoder: Decoder) throws {
    let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
    self.init(context: context)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int64.self, forKey: .identifier)
    name = try container.decode(String.self, forKey: .name)
    latitude = try container.decode(Double.self, forKey: .latitude)
    longitude = try container.decode(Double.self, forKey: .longitude)
    capacity = try container.decode(Int64.self, forKey: .capacity)
  }

  enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case name
    case latitude
    case longitude
    case capacity
  }
}

extension Cafeteria {

  public func updateMenu() -> Promise<[Meal]> {
    return updateMenu(request: URLRoute.menu(cafeteriaId: self.id))
  }

  func updateMenu(request: URLRequestConvertible) -> Promise<[Meal]> {
    return URLSession.shared.dataTask(.promise, with: request)
      .then { (response) in
        self.managedObjectContext!.mergingObjects().performPromise {
          try response.response.validateHTTPStatusCode()
          let decoder = JSONDecoder.persistent(context: self.managedObjectContext!)
          if #available(iOSApplicationExtension 10.0, *) {
            decoder.dateDecodingStrategy = .iso8601
          } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            decoder.dateDecodingStrategy = .formatted(formatter)
          }
          let menu = try decoder.decode([Meal].self, from: response.data)
          self.menu = NSSet(array: menu)
          try self.managedObjectContext!.save()
          return menu
        }
    }
  }
}
