//
//  CartViewController.swift
//  NellaiMarts
//
//  Created by admin on 11/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    
    var childViewController:ViewController! = nil
    var defaults:UserDefaults!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cartSegue"{
            self.defaults = UserDefaults.standard
            self.childViewController = segue.destination as? ViewController
            self.childViewController.loadUrl = defaults.string(forKey: "cartUrl")!
            self.childViewController.requestType = .url
        }
    }
}
