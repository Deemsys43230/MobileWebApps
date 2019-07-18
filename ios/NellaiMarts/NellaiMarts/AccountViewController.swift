//
//  CartViewController.swift
//  NellaiMarts
//
//  Created by admin on 11/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    var childViewController:ViewController! = nil
    var defaults:UserDefaults!
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear")
        self.defaults = UserDefaults.standard
        self.defaults.synchronize()
        let notificationDict = ["url":self.defaults.string(forKey: "accountUrl")]
        NotificationCenter.default.post(name: NSNotification.Name("SITE_URL"), object: nil, userInfo: notificationDict as [String : Any])
    }
    
}
