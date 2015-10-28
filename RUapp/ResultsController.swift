//
//  ResultsController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-10-28.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit

class ResultsController: UITableViewController {
    
    private func adjustInstets() {
        let topBarHeight = mainController.topBarHeight.constant
        tableView?.contentInset.top = topBarHeight + 10
        tableView?.scrollIndicatorInsets.top = topBarHeight
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustInstets()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        adjustInstets()
    }

    override func needsMenuTypeSelector() -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("Result", forIndexPath: indexPath)
    }
}
