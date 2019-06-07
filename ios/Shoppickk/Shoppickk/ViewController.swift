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



class ViewController: UIViewController,MFMailComposeViewControllerDelegate, WKNavigationDelegate,UIWebViewDelegate, UIScrollViewDelegate {
    var defaults:UserDefaults!
    
    

    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var webKitView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 219.0/255.0, green: 10.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 21.0)!]
        self.navigationItem.title = "Shoppickk"
        self.navigationController?.navigationBar.tintColor = .white
        
        let shareBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Share"), style: .plain, target: self, action: #selector(Share))
        let callBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Call"), style: .plain, target: self, action: #selector(Call))
        let emailBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Email"), style: .plain, target: self, action: #selector(Message))
        self.navigationItem.setRightBarButtonItems([emailBarButton,callBarButton], animated: true)
        let rateBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "thumbs up"), style: .plain, target: self, action: #selector(Rate))
        self.navigationItem.setLeftBarButtonItems([rateBarButton,shareBarButton], animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
    
    func LoadSite(){
        if let url = URL(string: defaults.string(forKey: "websiteUrl")!){
            let request = URLRequest(url: url)
            webKitView.load(request)
        }
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
    
    @objc func Rate(){
        if let url = NSURL(string: defaults.string(forKey: "iosRateusUrl")!), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL)
        }
    }
    
    func displayNetworkAlert() {
        let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Webkit and Scroll Deleagtes
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //print (Float(webKitView.estimatedProgress))
            self.progress.progress = Float(webKitView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let reachability = Reachability()!
        if reachability.connection != .none{
            decisionHandler(.allow)
            return
        }
        self.displayNetworkAlert()
        decisionHandler(.cancel)
    }


}

