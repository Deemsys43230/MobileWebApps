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
import BarcodeScanner

enum requestTypeEnum:Int {
    case url = 1
    case html = 2
}


class ViewController: UIViewController,MFMailComposeViewControllerDelegate, WKNavigationDelegate,UIWebViewDelegate,UIScrollViewDelegate,BarcodeScannerCodeDelegate,BarcodeScannerErrorDelegate,BarcodeScannerDismissalDelegate{
    
    
    var defaults:UserDefaults!
    var barCodeController:BarcodeScannerViewController! = nil
    var loadUrl:String?
    var requestType: requestTypeEnum!
    var navTitle:String?
    var fromSource:String?
    
    let script = "var style = document.createElement('style'); style.innerHTML = 'body { font-family: Arial; font-size: 15px; color: black; }'; document.getElementsByTagName('head')[0].appendChild(style);var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport' ); meta.setAttribute( 'content', 'width = device-width, initial-scale = 0.0 user-scalable = no' ); document.getElementsByTagName('head')[0].appendChild(meta);"
    
    //let cssStartingString = "<html><head><style>body{color: black;font-family: Arial;font-size: 30px;}</head><body>"
    let cssStartingString = "<html><head></head><body>"
    let cssClosingString = "</body></html>"

    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var webKitView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VC viewDidLoad")
        webKitView.scrollView.delegate = self
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(setValues(notification:)), name: NSNotification.Name(rawValue: "SITE_URL"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.fromSource = nil
        webKitView.scrollView.delegate = nil
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
                let composedString = "\(self.cssStartingString)\(html)\(self.cssClosingString)"
                print(composedString)
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
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 47.0/255.0, green: 199.0/255.0, blue: 0.0/255.0, alpha: 1.0)
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
    /*
    @objc func Rate(){
        if let url = NSURL(string: defaults.string(forKey: "iosRateusUrl")!), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL)
        }
    }*/
    
    @objc func Scan(){
        // Bar code scanning
        self.barCodeController = BarcodeScannerViewController()
        barCodeController.codeDelegate = self
        barCodeController.errorDelegate = self
        barCodeController.dismissalDelegate = self
        self.barCodeController.title = "Scan barcode"
        self.navigationController?.present(barCodeController, animated: true, completion: nil)
        
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if requestType == requestTypeEnum.html{
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if requestType == requestTypeEnum.html{
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    
    
    // MARK: - Scanner Delegates
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        // Process bar code and fetch the handle
        controller.reset()
        controller.dismiss(animated: true, completion: nil)
        // Load the webview with handle url
    }

    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
         print(error)
    }

    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
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
    
    //MARK:- ScrollView Delegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if requestType == requestTypeEnum.url{
            scrollView.setZoomScale(1.0, animated: false)
        }
    }

}

