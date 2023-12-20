//
//  ViewController.swift
//  Polimats
//
//  Created by Atakan Başaran on 20.12.2023.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    let webUrl = "https://polimats.com/"

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackButton()
        loadWebPage()
        navigationItem.leftBarButtonItem?.customView?.isHidden = true
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil) //We added observer to observe WebView.canGoBack to hide back button
        }
    
    func loadWebPage() {
        if let url = URL(string: webUrl) {
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.canGoBack) {
            if let newValue = change?[.newKey] as? Bool {
                updateBackButtonVisibility(canGoBack: newValue)
            }
        }
    }
    
    private func updateBackButtonVisibility(canGoBack: Bool) {
        navigationItem.leftBarButtonItem?.customView?.isHidden = !canGoBack
    }
    
    deinit { //to prevent potential memory leaks when the view controller is deallocated
           webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
       }
    
    
    private func setUpBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.tintColor, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    


}

