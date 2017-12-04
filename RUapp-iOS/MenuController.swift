//
//  MenuController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 16/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import RUappShared

class MenuController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let op = OtherOperation()
    
    let list = [
    [
        "type": "prato principal",
        "meta": "main",
        "name": "INDEFINIDO"
        ],
    [
        "type": "opção vegetariana",
        "meta": "vegetarian",
        "name": "INDEFINIDO"
        ],
    [
        "type": "sopa",
        "meta": "other",
        "name": "INDEFINIDO"
        ],
    [
        "type": "guarnição",
        "meta": "other",
        "name": "INDEFINIDO"
        ],
    [
        "type": "arroz",
        "meta": "other",
        "name": "INDEFINIDO"
        ],
    [
        "type": "feijão",
        "meta": "other",
        "name": "INDEFINIDO"
        ],
    [
        "type": "salada",
        "meta": "other",
        "name": "INDEFINIDO"
        ],
    [
        "type": "suco",
        "meta": "other"
        ],
    [
        "type": "sobremesa",
        "meta": "other",
        "name": "INDEFINIDO"
        ],
    [
        "type": "fruta",
        "meta": "other",
        "name": "INDEFINIDO"
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Wednesday"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cafeteria", style: .plain, target: nil, action: nil)
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "MealHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "MealHeader")
        tableView.register(UINib(nibName: "MealFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "MealFooter")
    }
}

extension MenuController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath) as! DishCell
        cell.title.text = list[indexPath.row]["type"]
        cell.value.text = list[indexPath.row]["name"]
        return cell
    }
}

extension MenuController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MealHeader") as! MealHeader
        header.label.text = "Section \(section)"
        header.image.tintColor = .darkGray
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MealFooter") as! MealFooter
        footer.image.tintColor = .darkGray
        return footer
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
}

class MealHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
}

class MealFooter: UITableViewHeaderFooterView {
    @IBOutlet weak var image: UIImageView!
}

class DishCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
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

private extension UIView {
    func with(tintColor: UIColor) -> Self {
        self.tintColor = tintColor
        return self
    }
}
