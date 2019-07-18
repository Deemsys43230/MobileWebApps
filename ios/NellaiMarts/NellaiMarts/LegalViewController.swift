//
//  LegalViewController.swift
//  NellaiMarts
//
//  Created by admin on 11/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import UIKit
import GraphQL_Swift
import Reachability
import MessageUI
import NVActivityIndicatorView

class LegalViewController: UITableViewController,UITabBarControllerDelegate,MFMailComposeViewControllerDelegate,NVActivityIndicatorViewable {
    var aboutUSContent:String!
    var TermsContent:String!
    var privacyContent:String!
    var refundPolicyContent:String!
    var faqContent:String!
    var defaults:UserDefaults!
    var indicator:NVActivityIndicatorView!
    var barButtonItem : UIBarButtonItem!
    @IBOutlet var table: UITableView!
    @IBOutlet weak var location: UILabel!
    let legalQuery = LegalQuery()
    let hostQuery = HostQuery()
    let reachability = Reachability()!
    
    override func viewWillAppear(_ animated: Bool) {
        defaults = UserDefaults.standard
        self.indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y:
            0, width: 20, height: 20), type: .lineSpinFadeLoader, color: UIColor.AppGreenColor())
        self.barButtonItem = UIBarButtonItem(customView: self.indicator)
        self.navigationItem.rightBarButtonItem = self.barButtonItem
        self.loadData()
        self.setupNavBar()
        
    }
    
    func loadData(forIndex index:Int? = nil){
        let manager = GraphQLManager()
        if reachability.connection != .none{
            self.indicator.startAnimating()
            manager.getDataForGraphQLRequest(withQuery: legalQuery) { (response, error) in
                if error == nil{
                    if index != nil{
                        self.defaults.set(index, forKey: "index")
                    }
                    let data = response!["data"] as! [AnyHashable:Any]
                    print(data)
                    let pages = data["pages"] as! [String:Any]
                    let edges = pages["edges"] as! [[String:Any]]
                    for edge in edges{
                        let node = edge["node"] as! [String:Any]
                        switch node["id"] as! String{
                        case self.defaults.string(forKey: "aboutus")!: // about us
                            self.aboutUSContent = (node["body"] as! String)
                            break;
                        case self.defaults.string(forKey: "faq")!: // faq
                            self.faqContent = (node["body"] as! String)
                            break;
                        case self.defaults.string(forKey: "privacy")!: // privacy
                            self.privacyContent = (node["body"] as! String)
                            break;
                        case self.defaults.string(forKey: "refund")!: // refund
                            self.refundPolicyContent = (node["body"] as! String)
                            break;
                        case self.defaults.string(forKey: "terms")!: // terms
                            self.TermsContent = (node["body"] as! String)
                            break;
                        default: break
                            // do nothing
                        }
                    }
                    self.loadHostData()
                }
            }
        }else{
            let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }
    
    func setupNavBar(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 21.0)!]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationItem.hidesBackButton = false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "main") as! ViewController
        
        if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                VC.loadUrl = self.aboutUSContent
                VC.requestType = .html
                VC.navTitle = "About Us"
                self.navigationController?.pushViewController(VC, animated: true)
                break;
            case 1:
                if let url = NSURL(string: "tel://\(self.defaults.string(forKey: "call")!)"), UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url as URL)
                }
                break;
            case 2:
                if !MFMailComposeViewController.canSendMail(){
                    print ("Mail service not available")
                    return
                }
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                composer.setToRecipients([self.defaults.string(forKey: "mail")!])
                self.present(composer, animated: true, completion: nil)
                break;
            case 3:
                VC.loadUrl = self.faqContent
                VC.requestType = .html
                VC.navTitle = "Faq's"
                self.navigationController?.pushViewController(VC, animated: true)
                break;
            default:
                let shareContent = "\(defaults.string(forKey: "share")!) \(" ") \(self.defaults.string(forKey: "iosRateusUrl")!)"
                let activityController = UIActivityViewController(activityItems: [shareContent], applicationActivities: [])
                self.present(activityController, animated: true, completion: nil)
                break;
                
            }
        }else if indexPath.section == 2{
            switch indexPath.row {
            case 0:
                VC.loadUrl = self.TermsContent
                VC.requestType = .html
                VC.navTitle = "Terms of Use"
                self.navigationController?.pushViewController(VC, animated: true)
                break;
            case 1:
                VC.loadUrl = self.privacyContent
                VC.requestType = .html
                VC.navTitle = "Privacy Policy"
                self.navigationController?.pushViewController(VC, animated: true)
                break;
            default:
                VC.loadUrl = self.refundPolicyContent
                VC.requestType = .html
                VC.navTitle = "Refund Policy"
                self.navigationController?.pushViewController(VC, animated: true)
                break;
            }
            
        }else{
            let storeOptions = UIAlertController(title: "Location", message: "Select location to switch the store", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            storeOptions.addAction(action)
            let storeLocations = defaults.value(forKey: "locations") as! [[String:Any]]
            for (index,item) in storeLocations.enumerated(){
                let action = UIAlertAction(title: item["location"] as? String, style: .default) { (UIAlertAction) in
                    self.updateLocationData(forIndex: index)
                }
                storeOptions.addAction(action)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")
            if let popOver = storeOptions.popoverPresentationController{
                popOver.sourceView = cell?.contentView
                popOver.sourceRect = tableView.headerView(forSection: 0)!.frame
            }
            self.present(storeOptions, animated: true, completion: nil)
            
        }
    }
    
    func updateLocationData(forIndex index:Int!){
        let locations = defaults.value(forKey: "locations")! as! [[String:Any]]
        defaults.setValuesForKeys(locations[index])
        defaults.synchronize()
        self.loadData(forIndex: index)
    }
    
    func loadHostData(){
        let manager = GraphQLManager()
        manager.getDataForGraphQLRequest(withQuery: hostQuery) { (response, error) in
            if error == nil{
                let data = response!["data"] as! [AnyHashable:Any]
                // save primary domain url to defaults
                let shop = data["shop"] as! [String:Any]
                let primaryDomain = shop["primaryDomain"] as! [String:Any]
                self.defaults.set("\(primaryDomain["url"] as! String)/cart", forKey: "cartUrl")
                self.defaults.set(primaryDomain["url"] as! String, forKey: "domain")
                self.defaults.set("\(primaryDomain["url"] as! String)/account", forKey: "accountUrl")
//                print(UserDefaults.standard.dictionaryRepresentation().values)
                self.defaults.synchronize()
            }
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.location.text = self.defaults.string(forKey: "location")
                self.table.reloadData()
            }
        }
    }
}


extension UIColor{
    class func AppGreenColor()-> UIColor{
        return UIColor(red: 47.0/255.0, green: 199.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
}

struct LegalQuery: GQLQuery {
    var variables: [String : Any]?
    var fragments: [GQLFragment]?
    var graphQLLiteral: String = """
    query{
    pages(first:100){
    edges{
      node{
        title
        id
        body
      }
    }
    }
    }
    """
    
    init() {
        
    }
    
}


