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
    
    let fileUrl:String = "https://mobilewebapps.s3.amazonaws.com/shoppickk.json"
    let reachability = Reachability()!
    
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        // page onload
        self.Indicator.startAnimating()
        self.navigationController?.navigationBar.isHidden = true
        
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
                    let dict = response.dictionaryObject as! [String:String]
                    let defaults = UserDefaults.standard
                    defaults.setValuesForKeys(dict)
                    defaults.synchronize()
                    // Navigate
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let VC = storyboard.instantiateViewController(withIdentifier: "main") as! ViewController
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            }
        }
    }
}
