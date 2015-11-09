//
//  Menu.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-09.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

var cache = Array<Menu.Dish>()

public class Menu {//{"id":11,"tipo_refeicao_id":2,"data":2015-10-12,"status":"fechado","cardapio":[]}
    
//    let id: Int
//    let meal: Meal
//    let date: NSDate
//    let status: Status
//    let items: [Item]?
    
    public class func get(cafeteria: Cafeteria, completion: (menu: AnyObject?, error: ErrorType?) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL.appGetMenu(cafeteria), completionHandler: { (data, response, error) -> Void in
            
            do {
                guard let data = data else {
                    throw error ?? Error.NoData
                }
                
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
//                let newInstitution = try Institution(dict: jsonObj)
                print(jsonObj)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(menu: nil, error: nil)
                })
            } catch {
                print(error)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(menu: nil, error: error)
                })
            }
            
        }).resume()
    }
    
    public class Item {//{"comida_id":34,"comida_nome":"Fricass","tipo_comida_id":1,"meta":"principal","tipo_comida_nome":"Prato principal"}
        
//        let id: Int
//        let name: String?
//        let dish: Dish
//        let meta: Meta
        
        
        
        public enum Meta: String {
            case Traditional = "principal"
            case Vegetarian = "vegetariano"
            case Other = "outro"
        }
    }
    
    public class Dish {
        let id: Int
        let name: String
        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    public enum Status: String {
        case Closed = "fechado"
        case Open = "aberto"
    }
}
