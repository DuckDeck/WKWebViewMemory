//
//  ViewController.swift
//  WebViewMemory
//
//  Created by Stan Hu on 2022/3/6.
//

import UIKit
import WebKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WKWebView 内存问题"
        view.backgroundColor = UIColor.white
        let btnOpenWeb = UIButton(frame: CGRect(x: 10, y: 50, width: 100, height: 40))
        btnOpenWeb.setTitle("打开网页", for: .normal)
        btnOpenWeb.setTitleColor(UIColor.blue, for: .normal)
        btnOpenWeb.addTarget(self, action: #selector(openWebPage), for: .touchUpInside)
        view.addSubview(btnOpenWeb)
        // Do any additional setup after loading the view.
    }

    @objc func openWebPage(){
        let vc = webVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

}

class webVC:UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(progressView)
        progressView.frame = CGRect(x: 0, y: 30, width: UIScreen.main.bounds.size.width, height: 5)
        
        view.addSubview(webView)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new,.old], context: nil)
        webView.frame = CGRect(x: 0, y: 35, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 100)
        
        view.addSubview(btnClose)
        btnClose.frame = CGRect(x: 100, y: webView.frame.height + 40, width: 50, height: 40)
        
        let req = URLRequest(url: URL(string: "https://www.sohu.com/")!,cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        webView.load(req)
    }
    

    
    @objc func close(){
        webView.removeFromSuperview()
        clearCache()
        dismiss(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)

        }
    }
    
    fileprivate func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }

   
    
    lazy var btnClose : UIButton = {
        let v = UIButton()
        v.setTitle("关闭", for: .normal)
        v.setTitleColor(UIColor.blue, for: .normal)
        v.addTarget(self, action: #selector(close), for: .touchUpInside)
        return v
    }()
    
    lazy var progressView: UIProgressView = {
        let v = UIProgressView()
        v.tintColor = UIColor.red
        return v
    }()
    
    lazy var webView : MMWwb = {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let v = MMWwb.init(frame: CGRect.zero, configuration: config)
        v.isMultipleTouchEnabled = true
        v.navigationDelegate = self
        v.uiDelegate = self
        v.autoresizesSubviews = true
        v.scrollView.alwaysBounceVertical = true
        v.scrollView.contentInsetAdjustmentBehavior = .never
        v.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        v.scrollView.scrollIndicatorInsets = v.scrollView.contentInset
        return v
    }()
    
    deinit {
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.configuration.userContentController.removeAllUserScripts()
        print("webVC 已经被deinit")
    }
}

extension webVC:WKUIDelegate,WKNavigationDelegate{
    
}

class MMWwb:WKWebView{
    deinit {
        print("=========WKWebView deinit =========")
    }
}
