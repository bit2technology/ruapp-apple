//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

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
