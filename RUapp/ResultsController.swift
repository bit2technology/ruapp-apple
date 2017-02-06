//
//  ResultsController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-10-28.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit

class ResultsController: UITableViewController {
    
    fileprivate func adjustInstets() {
        let topBarHeight = mainController.topBarHeight.constant
        tableView?.contentInset.top = topBarHeight + 10
        tableView?.scrollIndicatorInsets.top = topBarHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustInstets()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        adjustInstets()
    }

    override func needsMenuTypeSelector() -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Result", for: indexPath)
    }
}
