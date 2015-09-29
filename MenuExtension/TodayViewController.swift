//
//  TodayViewController.swift
//  MenuExtension
//
//  Created by Igor Camilo on 15-09-28.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import NotificationCenter

let cardapio = ["Arroz": "Branco e Integral",
    "Feijão": "Preto",
    "Macarrão": "Tomate e Manjericão",
    "Guarnição": "Farofa com Cenoura e Ovos",
    "Vegetariano": "Omelete",
    "Prato Principal": "Carne de Panela com Mandioca",
    "Salada": "Almeirão/Acelga, Beterraba Ralada, Abobrinha Ralada"]

class TodayMenuController: UIViewController, NCWidgetProviding {
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}