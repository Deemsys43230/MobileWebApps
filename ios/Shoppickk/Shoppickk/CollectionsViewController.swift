//
//  CollectionsViewController.swift
//  NellaiMarts
//
//  Created by admin on 11/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import UIKit
import GraphQL_Swift
import Reachability
import NVActivityIndicatorView

struct Collections: Codable{
    var collectionTitle:String!
    var collectionImage:String!
    var handle:String!
}

@IBDesignable class CustomImageView:UIImageView{
    @IBInspectable var rounded: Bool = false {
        didSet {
           layer.cornerRadius = rounded ? frame.size.height / 2 : 0
             layer.masksToBounds = true
        }
    }
}

class collectionCell:UITableViewCell{
    @IBOutlet weak var collectionImage: CustomImageView!
    @IBOutlet weak var collectionTitle: UILabel!
}

class CollectionsViewController: UIViewController,NVActivityIndicatorViewable,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var indicator:NVActivityIndicatorView!
    var barButtonItem : UIBarButtonItem!
    var collectionData: [Collections]! = []
    var defaults:UserDefaults!
    override func viewWillAppear(_ animated: Bool) {
        self.setupNavBar()
        let manager = GraphQLManager()
        let collectionsQuery = CollectionsQuery()
        let reachability = Reachability()!
        defaults = UserDefaults.standard
        self.indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y:
            0, width: 20, height: 20), type: .lineSpinFadeLoader, color: .white)
        self.barButtonItem = UIBarButtonItem(customView: self.indicator)
        self.navigationItem.rightBarButtonItem = self.barButtonItem
        self.table.tableFooterView = UIView()
        if reachability.connection != .none{
            self.indicator.startAnimating()
            manager.getDataForGraphQLRequest(withQuery: collectionsQuery) { (response, error) in
                self.collectionData = []
                if error == nil{
                    let data = response!["data"] as! [AnyHashable:Any]
                    let collectionsData = data["collections"] as! [String:Any]
                    let collectionEdges = collectionsData["edges"] as! [[String:Any]]
                    for collectionEdge in collectionEdges{
                        let collectionNode = collectionEdge["node"] as! [String:Any]
                        let handle = collectionNode["handle"] as! String
                        let title = collectionNode["title"] as! String
                        var image = ""
                        let products = collectionNode["products"] as! [String:Any]
                        let productEdges = products["edges"] as! [[String:Any]]
                        for productEdge in productEdges{
                            let productNode = productEdge["node"] as! [String:Any]
                            let images = productNode["images"] as! [String:Any]
                            let imageEdges = images["edges"] as! [[String:Any]]
                            for imageEdge in imageEdges{
                                let imageNode = imageEdge["node"] as! [String:Any]
                                image = imageNode["originalSrc"] as! String
                            }
                        }
                     self.collectionData.append(Collections(collectionTitle: title, collectionImage: image, handle: handle))
                    }
                }
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.table.reloadData()
                }
            }
        }else{
            let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func setupNavBar(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 21.0)!]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 219.0/255.0, green: 10.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationItem.title = "Collections"
        
    }
    
    // MARk: TableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "main") as! ViewController
        VC.loadUrl = "\(defaults.string(forKey: "domain")!)/collections/\(self.collectionData[indexPath.row].handle!)"
        VC.requestType = .url
        VC.fromSource = "CollectionsList"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collectionData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCell(withIdentifier: "cell") as! collectionCell
        cell.tag = indexPath.row
        if self.collectionData.count == 0{
            return cell
        }
        cell.collectionTitle.text = self.collectionData[indexPath.row].collectionTitle
        guard self.collectionData[indexPath.row].collectionImage.count>0 else {
            return cell
        }
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: URL(string: self.collectionData[indexPath.row].collectionImage)!, completionHandler: { (data, response, error) in
                if error == nil{
                    DispatchQueue.main.async() { () -> Void in
                        if cell.tag == indexPath.row{
                            if let imageData = UIImage(data: data!){
                                cell.collectionImage.image = imageData
                            }
                        }
                    }
                }
            }).resume()
        }
        return cell
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
