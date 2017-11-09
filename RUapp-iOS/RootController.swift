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
        
//        guard Student.current != nil else {
            performSegue(withIdentifier: "EditStudent", sender: nil)
//            return
//        }
    }
    
    @IBAction private func unwindToRoot(segue: UIStoryboardSegue) { }
}
