//
//  MenuController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 16/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import RUappShared

class MenuController: UITableViewController {
    
    let op = OtherOperation()
}

class OtherOperation: Operation {
    
    let op = UpdateMenuOperation(restaurantId: 1)
    
    override init() {
        super.init()
        addDependency(op)
        OperationQueue.main.addOperation(self)
    }
    
    override func main() {
        try! print(op.parse())
        print(Meal.next)
    }
}
