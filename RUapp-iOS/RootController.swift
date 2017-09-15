//
//  RootController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit
import RUappShared

class RootController: UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard Student.shared != nil, Institution.shared != nil else {
            try? Student.unregister()
            try? Institution.unregister()
            performSegue(withIdentifier: "EditStudent", sender: nil)
            return
        }
    }
    
    @IBAction private func unwindToRoot(segue: UIStoryboardSegue) { }
}
