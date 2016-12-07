// Copyright (c) 2016 Peter Siegesmund <peter.siegesmund@icloud.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import WebKit

// TODO: Handle login failure > specific actions for cancellation, for example
// TODO: Gotchas: connecting over wss, but registered domain is http... 
// TODO: Activity indicator?
// TODO: Add redirect not popup; register as web app when setting up services to instructions
// TODO: Login first with stored token

open class MeteorOAuthDialogViewController: UIViewController, WKNavigationDelegate {
    
    // App must be set to redirect, rather than popup
    // https://github.com/meteor/meteor/wiki/OAuth-for-mobile-Meteor-clients#popup-versus-redirect-flow
    
    var meteor = Meteor.client
    
    open var navigationBar:UINavigationBar!
    open var cancelButton:UIBarButtonItem!
    open var webView:WKWebView!
    open var url:URL!
    open var serviceName: String?
    
    override open func viewDidLoad() {
        
        navigationBar = UINavigationBar() // Offset by 20 pixels vertically to take the status bar into account
        let navigationItem = UINavigationItem()
        
        navigationItem.title = "Login"

        if let name = serviceName {
            navigationItem.title = "Login with \(name)"
        }
        
        
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MeteorOAuthDialogViewController.close))
        navigationItem.rightBarButtonItem = cancelButton
        navigationBar!.items = [navigationItem]
                
        // Configure WebView
        let request = URLRequest(url:url)
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.load(request)
        
        self.view.addSubview(webView)
        self.view.addSubview(navigationBar)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)
        webView.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func signIn(_ token: String, secret: String) {
        let params = ["oauth":["credentialToken": token, "credentialSecret": secret]]
        
        var user = UserDefaults.standard
        user.setValue(secret, forKey: "secret_key")
        user.setValue(token, forKey: "token_key")

        Meteor.client.login(params) { result, error in
            print("Meteor login attempt \(result), \(error)")
            self.close()
        }
    }
    
    //
    //
    //  WKNavigationDelegate Methods
    //
    //
    
    /* Start the network activity indicator when the web view is loading */
    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /* Stop the network activity indicator when the loading finishes */
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // This works to get the credentialSecret, credentialToken, redirectUrl etc.
        webView.evaluateJavaScript("JSON.parse(document.getElementById('config').innerHTML)",
            completionHandler: { (html: AnyObject?, error: NSError?) in
                if let json = html {
                    if let secret = json["credentialSecret"] as? String,
                        let token = json["credentialToken"] as? String {
                            webView.stopLoading() // Is there a possible race condition here?
                        
                            self.signIn(token, secret: secret)
                    }
                } else {
                    print("There was no json here")
                }
                
                // TODO: What if there's an error?, if the login fails
        })
    }
    
    
}
