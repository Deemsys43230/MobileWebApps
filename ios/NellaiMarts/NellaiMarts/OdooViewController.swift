//
//  OdooViewController.swift
//  NellaiMarts
//
//  Created by admin on 23/08/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Reachability
import NVActivityIndicatorView

class OdooViewContoller: UIViewController,WKNavigationDelegate,UIWebViewDelegate,UIScrollViewDelegate{

    @IBOutlet weak var WebView: WKWebView!
    
    var defaults:UserDefaults!
    var indicator:NVActivityIndicatorView!
    var barButtonItem : UIBarButtonItem!
    var locationButtonItem : UIBarButtonItem!
    var locations:[[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("odoo viewDidLoad")
        WebView.scrollView.delegate = self
        self.defaults = UserDefaults.standard
        locations = defaults.value(forKey: "locations") as! [[String : String]]
        self.indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y:
            0, width: 20, height: 20), type: .lineSpinFadeLoader, color: .white)
        self.barButtonItem = UIBarButtonItem(customView: self.indicator)
        self.navigationItem.rightBarButtonItem = self.barButtonItem
        self.locationButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(SelectLocation))
        self.navigationItem.leftBarButtonItem = self.locationButtonItem
        self.setupNavBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        WebView.scrollView.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Odoo viewDidAppear")
        self.WebView.navigationDelegate = self
        self.WebView.scrollView.delegate = self
        let reachability = Reachability()!
        if reachability.connection != .none{
            let activeIndex = defaults.value(forKey: "index") as! Int
            self.locationButtonItem.title = locations[activeIndex]["location"]!
            if let url = URL(string: locations[activeIndex]["websiteUrl"]!){
                let request = URLRequest(url: url)
                WebView.load(request)
                self.indicator.startAnimating()
            }else{
                self.displayNetworkAlert()
            }
        }
        WebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
        
    func displayNetworkAlert() {
        let alertController = UIAlertController(title: "No Internet ☹", message: "Please check your internet connection.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupNavBar(){
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 21.0)!], for: .normal)
        self.navigationController?.navigationBar.tintColor = UIColor(hex: defaults.string(forKey: "Fhex")!)
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: defaults.string(forKey: "Bhex")!)
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationItem.title = ""
    }
    
    @objc func SelectLocation(){
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
        if let popOver = storeOptions.popoverPresentationController{
            popOver.barButtonItem = self.locationButtonItem
        }
        self.present(storeOptions, animated: true, completion: nil)
    }
    
    func updateLocationData(forIndex index:Int!){
        let locations = defaults.value(forKey: "locations")! as! [[String:Any]]
        defaults.setValuesForKeys(locations[index])
        defaults.set(index, forKey: "index")
        defaults.synchronize()
        self.locationButtonItem.title = (locations[index]["location"]! as! String)
        if let url = URL(string: locations[index]["websiteUrl"]! as! String){
            let request = URLRequest(url: url)
            WebView.load(request)
            self.indicator.startAnimating()
        }
    }
        
    // MARK: - Webkit and Scroll Delegates
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //print (Float(WebView.estimatedProgress))
            if (Float(WebView.estimatedProgress)) == 1.0{
                if self.indicator.isAnimating{
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let reachability = Reachability()!
        if reachability.connection != .none{
            decisionHandler(.allow)
            self.indicator.startAnimating()
            return
        }
        self.displayNetworkAlert()
        decisionHandler(.cancel)
    }
        
    //MARK:- ScrollView Delegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.setZoomScale(1.0, animated: false)
    }
}

extension UIColor{
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
