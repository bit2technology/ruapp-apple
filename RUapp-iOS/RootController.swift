//
//  RootController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import RUappShared

class RootController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    @IBAction private func unwindToRoot(segue: UIStoryboardSegue) { }
}

extension RootController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !viewController.needsLogin || Student.current.isSaved else {
            performSegue(withIdentifier: "EditStudent", sender: nil)
            return false
        }
        return true
    }
}

extension UIViewController {
    @objc var needsLogin: Bool {
        return false
    }
}

extension UINavigationController {
    override var needsLogin: Bool {
        return viewControllers.first?.needsLogin ?? false
    }
}
