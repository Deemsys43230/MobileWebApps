//
//  ViewController.swift
//  Shoppickk
//
//  Created by admin on 04/06/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import UIKit
import MessageUI
import WebKit
import Reachability

enum requestTypeEnum:Int {
    case url = 1
    case html = 2
}

class ViewController: UIViewController,MFMailComposeViewControllerDelegate, WKNavigationDelegate,UIWebViewDelegate,UIScrollViewDelegate{
    
    
    var defaults:UserDefaults!
    var loadUrl:String?
    var requestType: requestTypeEnum!
    var navTitle:String?
    var fromSource:String?

    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var webKitView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VC viewDidLoad")
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(setValues(notification:)), name: NSNotification.Name(rawValue: "SITE_URL"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.fromSource = nil
    }
    
    @objc func setValues(notification:NSNotification){
        print(notification)
        self.loadUrl = notification.userInfo?["url"] as? String
        self.requestType = requestTypeEnum.url
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("VC viewDidAppear")
        self.defaults = UserDefaults.standard
        self.webKitView.navigationDelegate = self
        self.webKitView.scrollView.delegate = self
        let reachability = Reachability()!
        if reachability.connection != .none{
            self.LoadSite()
        }else{
            self.displayNetworkAlert()
        }
        webKitView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func LoadSite(){
        switch requestType.rawValue {
        case requestTypeEnum.html.rawValue:
            if let html = self.loadUrl{
                webKitView.loadHTMLString(html, baseURL: nil)
            }
            self.setupNavBar()
            break;
        default:
            if let url = URL(string: self.loadUrl!){
                let request = URLRequest(url: url)
                webKitView.load(request)
            }
            break;
        }
        
    }
    
    func setupNavBar(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 21.0)!]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 219.0/255.0, green: 10.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationItem.title = self.navTitle!
    }
    
    @objc func Call(){
        if let url = NSURL(string: "tel://\(defaults.string(forKey: "call")!)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL)
        }
    }
    
    @objc func Message(){
        if !MFMailComposeViewController.canSendMail(){
          print ("Mail service not available")
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([defaults.string(forKey: "mail")!])
        self.present(composer, animated: true, completion: nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc func Share(){
        let shareContent = "\(defaults.string(forKey: "share")!) \(" ") \(defaults.string(forKey: "iosRateusUrl")!)"
        let activityController = UIActivityViewController(activityItems: [shareContent], applicationActivities: [])
        self.present(activityController, animated: true, completion: nil)
    }

    func displayNetworkAlert() {
        let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Webkit and Scroll Delegates
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //print (Float(webKitView.estimatedProgress))
            self.progress.progress = Float(webKitView.estimatedProgress)
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let reachability = Reachability()!
        if reachability.connection != .none{
            decisionHandler(.allow)
            if self.fromSource == "CollectionsList"{
                self.defaults.set(webView.url?.absoluteString, forKey: "collectionUrl")
                self.defaults.synchronize()
            }
            return
        }
        self.displayNetworkAlert()
        decisionHandler(.cancel)
    }
    
    //MARK:- Cart Delegate
    func SetCartUrl(url: String!) {
        print("called delegate")
        self.loadUrl = url
        self.requestType = .url
    }
    
    //MARK:- Account Delegate
    func SetAccountUrl(url: String!) {
        print("called delegate")
        self.loadUrl = url
        self.requestType = .url
    }
    

}

