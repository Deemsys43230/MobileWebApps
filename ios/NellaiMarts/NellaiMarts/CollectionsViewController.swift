//
//  CollectionsViewController.swift
//  NellaiMarts
//
//  Created by admin on 11/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import UIKit
import GraphQL_Swift
import  Reachability

class CollectionsViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupNavBar()
        let manager = GraphQLManager()
        let collectionsQuery = CollectionsQuery()
        let reachability = Reachability()!
        if reachability.connection != .none{
            manager.getDataForGraphQLRequest(withQuery: collectionsQuery) { (response, error) in
                if error == nil{
                    let data = response!["data"] as! [AnyHashable:Any]
                    print(data)
                    // Render collection data
                }
            }
        }else{
            let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func button_tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "main") as! ViewController
        VC.loadUrl = "https://nellai-marts-inc.myshopify.com/collections/grocerys"
        VC.requestType = .url
        self.navigationController?.pushViewController(VC, animated: true)
       
    }
    func setupNavBar(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 21.0)!]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 47.0/255.0, green: 199.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationItem.title = "Collections"
        
    }
}


struct CollectionsQuery: GQLQuery {
    var variables: [String : Any]?
    var fragments: [GQLFragment]?
    var graphQLLiteral: String = """
    query{
    collections(first: 250) {
    edges {
      node {
        handle
        title
        products(first:1) {
          edges {
            node {
              title
              images(first: 1) {
                edges {
                  node {
                    originalSrc
                  }
                }
              }
            }
          }
        }
      }
    }
    }
    }

    """
    
    init() {
        
    }
    
}
