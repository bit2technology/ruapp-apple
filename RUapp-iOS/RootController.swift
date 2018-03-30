//
//  RootController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 28/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit
import RUappShared

class RootController: UITabBarController {

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if Student.default() == nil {
      performSegue(withIdentifier: "PresentEditStudent", sender: nil)
    }
  }
}
