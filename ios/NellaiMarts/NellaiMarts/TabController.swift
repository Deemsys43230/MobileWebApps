//
//  TabController.swift
//  NellaiMarts
//
//  Created by admin on 11/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import Foundation
import UIKit
import GraphQL_Swift
import Reachability

class TabController:UITabBarController,UITabBarControllerDelegate{
    
    @IBOutlet weak var tabBarControl: UITabBar!
    
    override func viewDidLoad() {
        let firsTabItem = (self.tabBarControl.items?[0])! as UITabBarItem
        firsTabItem.image = #imageLiteral(resourceName: "Gfalling-star").withRenderingMode(.alwaysOriginal)
        firsTabItem.selectedImage = #imageLiteral(resourceName: "Cfalling-star").withRenderingMode(.alwaysOriginal)
        firsTabItem.title = "Shop"
        
        let secondTabItem = (self.tabBarControl.items?[1])! as UITabBarItem
        secondTabItem.image = #imageLiteral(resourceName: "Gbasket").withRenderingMode(.alwaysOriginal)
        secondTabItem.selectedImage = #imageLiteral(resourceName: "Cbasket").withRenderingMode(.alwaysOriginal)
        secondTabItem.title = "Cart"
        
        let thirdTabItem = (self.tabBarControl.items?[2])! as UITabBarItem
        thirdTabItem.image = #imageLiteral(resourceName: "Gboy").withRenderingMode(.alwaysOriginal)
        thirdTabItem.selectedImage = #imageLiteral(resourceName: "Cboy").withRenderingMode(.alwaysOriginal)
        thirdTabItem.title = "Account"
        
        let fourthTabItem = (self.tabBarControl.items?[3])! as UITabBarItem
        fourthTabItem.image = #imageLiteral(resourceName: "Ggdpr").withRenderingMode(.alwaysOriginal)
        fourthTabItem.selectedImage = #imageLiteral(resourceName: "Cgdpr").withRenderingMode(.alwaysOriginal)
        fourthTabItem.title = "Legal"
        
        self.tabBarControl.unselectedItemTintColor = UIColor.gray
        self.tabBarControl.tintColor = UIColor(red: 253.0/255.0, green: 167.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let hostQuery = HostQuery()
        let manager = GraphQLManager()
        var defaults:UserDefaults!
        let reachability = Reachability()!
        if reachability.connection != .none{
            manager.getDataForGraphQLRequest(withQuery: hostQuery) { (response, error) in
                if error == nil{
                    let data = response!["data"] as! [AnyHashable:Any]
                    // save primary domain url to defaults
                    let shop = data["shop"] as! [String:Any]
                    let primaryDomain = shop["primaryDomain"] as! [String:Any]
                    defaults = UserDefaults.standard
                    defaults.set("\(primaryDomain["url"] as! String)/cart", forKey: "cartUrl")
                    defaults.set(primaryDomain["url"] as! String, forKey: "domain")
                    defaults.set("\(primaryDomain["url"] as! String)/account", forKey: "accountUrl")
                    defaults.synchronize()
                }
            }
        }else{
            let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
}

struct HostQuery: GQLQuery {
    
    var graphQLLiteral: String = """
    query{
    shop {
    name
    primaryDomain {
      url
      host
    }
    }
    }
    """
    
    var fragments: [GQLFragment]?
    
    var variables: [String : Any]?
    
    init() {
        
    }
    
}






