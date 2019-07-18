//
//  CartViewController.swift
//  NellaiMarts
//
//  Created by admin on 11/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import UIKit


class CartViewController: UIViewController {
    
    var childViewController:ViewController! = ViewController()
    var defaults:UserDefaults!
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("cart viewDidAppear ")
        self.defaults = UserDefaults.standard
        self.defaults.synchronize()
        let notificationDict = ["url":self.defaults.string(forKey: "cartUrl")]
        NotificationCenter.default.post(name: NSNotification.Name("SITE_URL"), object: nil, userInfo: notificationDict as [String : Any])
        
    }
    
    
}
