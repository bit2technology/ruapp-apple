//
//  Configuration.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 29/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common

public func configure(app: UIApplication?) {
    CoreDataContainer.configuration = (Bundle(for: Student.self), "group.technology.bit2.ruapp")
    URLSessionDataTaskOperation.countObserver = { [weak app] (count) in
        DispatchQueue.main.async {
            app?.isNetworkActivityIndicatorVisible = count > 0
        }
    }
}
