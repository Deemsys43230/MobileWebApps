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
    @IBOutlet var table: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        let manager = GraphQLManager()
        let legalQuery = LegalQuery()
        let reachability = Reachability()!
        defaults = UserDefaults.standard
        print(self.table.frame.width,self.table.frame.height)
        self.indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), type: .ballPulse, color: UIColor.AppGreenColor())
        self.navigationItem.titleView = self.indicator
        if reachability.connection != .none{
            self.indicator.startAnimating()
            manager.getDataForGraphQLRequest(withQuery: legalQuery) { (response, error) in
                if error == nil{
                    let data = response!["data"] as! [AnyHashable:Any]
                    print(data)
                    let pages = data["pages"] as! [String:Any]
                    let edges = pages["edges"] as! [[String:Any]]
                    for edge in edges{
                        let node = edge["node"] as! [String:Any]
                        switch node["id"] as! String{
                        case "Z2lkOi8vc2hvcGlmeS9QYWdlLzM5MTI3Mjg1ODQw": // about us
                            self.aboutUSContent = (node["body"] as! String)
                        break;
                        case "Z2lkOi8vc2hvcGlmeS9QYWdlLzM5MTI3MzE4NjA4": // faq
                            self.faqContent = (node["body"] as! String)
                        break;
                        case "Z2lkOi8vc2hvcGlmeS9QYWdlLzM5MTI3MzUxMzc2": // privacy
                            self.privacyContent = (node["body"] as! String)
                        break;
                        case "Z2lkOi8vc2hvcGlmeS9QYWdlLzM5MTI3NDQ5Njgw": // refund
                            self.refundPolicyContent = (node["body"] as! String)
                        break;
                        case "Z2lkOi8vc2hvcGlmeS9QYWdlLzM5MTI3NTE1MjE2": // terms
                            self.TermsContent = (node["body"] as! String)
                        break;
                        default: break
                            // do nothing
                        }
                    }
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                    }
                }
            }
        }else{
            let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        self.setupNavBar()
        
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
        
        if indexPath.section == 0{
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
        }else if indexPath.section == 1{
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
