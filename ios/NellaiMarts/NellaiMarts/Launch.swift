//
//  Launch.swift
//  Shoppickk
//
//  Created by admin on 04/06/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import Alamofire
import SwiftyJSON


class Launch: UIViewController {
    
    let fileUrl:String = "https://mobilewebapps.s3.amazonaws.com/nellaimart.json"
    let reachability = Reachability()!
    
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        // page onload
        self.Indicator.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    
    
    @objc func reachabilityChanged(note:Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            //cellular connection received
            print("cellular connection")
            self.loadData()
        case .wifi:
            // wifi connection received
            print("Wifi connection")
             self.loadData()
        case .none:
            // no connection
            print("No connection")
            let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillAppear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    func loadData(){
        Alamofire.request(self.fileUrl).responseData { (responseData) in
            //print(responseData.result.value as Any)
            if responseData.result.value != nil{
                if let response = try? JSON(data: responseData.result.value!, options: .mutableContainers){
                    self.Indicator.stopAnimating()
                    let defaults:UserDefaults = UserDefaults.standard
                    let sourceData = response.dictionaryObject
                    // From Odoo
                    if sourceData!["source"] as! String == "odoo"{
                        print("From Odoo")
                        let locations = sourceData!["odoo"] as! [[String:String]]
                        var dict:Dictionary! = [:]
                        if let index = defaults.value(forKey: "index") {
                            dict = locations[index as! Int]
                        }else{
                            dict = locations[0]
                            defaults.set(0, forKey: "index")
                        }
                        print(dict!)
                        defaults.setValuesForKeys(dict as! [String : Any])
                        defaults.set(locations, forKey: "locations")
                        defaults.synchronize()
                        print(defaults.value(forKey: "locations")!)
                        //navigate to odoo webpage
                    }else{
                        // From Shopify
                        let locations = sourceData!["shopify"] as! [[String:String]]
                        var dict:Dictionary! = [:]
                        if let index = defaults.value(forKey: "index") {
                            dict = locations[index as! Int]
                        }else{
                            dict = locations[0]
                            defaults.set(0, forKey: "index")
                        }
                        print(dict!)
                        defaults.setValuesForKeys(dict as! [String : Any])
                        defaults.set(locations, forKey: "locations")
                        defaults.synchronize()
                        print(defaults.value(forKey: "locations")!)
                        // Navigate to shopify webpage
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let VC = storyboard.instantiateViewController(withIdentifier: "TabVC") as! TabController
                        self.present(VC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
