//
//  AGWDedicatedWebViewController.swift
//  AGW Dedicated Web Browser
//
//  Created by Stefan Agapie on 5/1/15.
//  Copyright (c) 2015 aGupieWare. All rights reserved.
//

import UIKit
import WebKit

class AGWDedicatedWebViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Constant Properties
    
    let webPageRoot : String = "wikipedia.org"
    let webPageURL : NSURL = NSURL(string: "https://www.wikipedia.org")!
    let webPageTitle : String = "Dedicated Web Browser"
    let minimumProgressValue : Float = 0.05
    
    let navBarHeight : CGFloat = 44
    let toolBarHeight : CGFloat = 44
    
    
    // MARK: - View Properties
    
    var agwWebView : WKWebView = WKWebView()

    @IBOutlet weak var agwWebViewContainer: UIView!
    @IBOutlet weak var agwBackwardButton: UIBarButtonItem!
    @IBOutlet weak var agwForwardButton: UIBarButtonItem!
    @IBOutlet weak var agwRefreshButton: UIBarButtonItem!
    @IBOutlet weak var agwNavigationBar: UINavigationBar!
    @IBOutlet weak var agwNavigationBarTitleItem: UINavigationItem!
    @IBOutlet weak var agwProgressView: UIProgressView!
    
    
    // MARK: - User Input Handlers
    
    @IBAction func agwBackwardButtonPressed(sender: UIBarButtonItem) {
        
        self.agwWebView.goBack()
    }
    
    @IBAction func agwForwardButtonPressed(sender: UIBarButtonItem) {
        
        self.agwWebView.goForward()
    }
    
    @IBAction func agwRefreshButtonPressed(sender: UIBarButtonItem) {
        
        self.agwProgressView.setProgress(self.minimumProgressValue, animated: false)
        
        self.agwWebView.reloadFromOrigin()
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.agwNavigationBarTitleItem.title = self.webPageTitle
        
        setupWKWebView()
        
        setupWKWebViewScrollViewInsets()
        
        setupWKWebViewKVO()
        
        disableForwardAndBackButtons()
        
        hideProgressIndicator()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadSite()
    }
    
    deinit {
        
        self.teardownWKWebViewKVO()
    }
    
    
    // MARK: Core Functionality
    
    /// Load default site
    func loadSite() {
        
        let request = NSURLRequest(URL: self.webPageURL)
        
        self.agwWebView.loadRequest(request)
    }
    
    
    // MARK: - Setup and Teardown Methods

    /// Setup WKWebView
    func setupWKWebView() {
        
        // Prevent automatically generated autolayout constraints //
        self.agwWebView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Web View to view hierarchy //
        self.agwWebViewContainer.insertSubview(self.agwWebView, atIndex: 0)
        
        // Autolayout constraints define the size and position of	//
        // the web view to equal to that of the web view container	//
        self.agwWebViewContainer.addConstraint(NSLayoutConstraint(item: self.agwWebView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.agwWebViewContainer, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
        self.agwWebViewContainer.addConstraint(NSLayoutConstraint(item: self.agwWebView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.agwWebViewContainer, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
        self.agwWebViewContainer.addConstraint(NSLayoutConstraint(item: self.agwWebView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.agwWebViewContainer, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0))
        self.agwWebViewContainer.addConstraint(NSLayoutConstraint(item: self.agwWebView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.agwWebViewContainer, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0))
        
        // Browser Properties and Delegate //
        self.agwWebView.allowsBackForwardNavigationGestures = true
        self.agwWebView.navigationDelegate = self
    }
    
    /// Apply WKWebView Scroll View Top and Bottom Insets
    func setupWKWebViewScrollViewInsets() {
        
        let insets = UIEdgeInsetsMake(self.navBarHeight, 0, self.toolBarHeight, 0)
        
        self.agwWebView.scrollView.contentInset = insets
        self.agwWebView.scrollView.scrollIndicatorInsets = insets
    }
    
    /// Setup KVO on Web View load progress and forward/backward navigation availability
    func setupWKWebViewKVO() {
        
        // Observe when changes to estimatedProgress are made -- an indication of a loading in progress //
        self.agwWebView.addObserver(self, forKeyPath: "estimatedProgress", options: ([.New, .Old]), context: nil)
        
        // Observe when changes to loading are made -- an indication of when loading starts and stops //
        self.agwWebView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        
        // Observe when changes to canGoForward are made -- an indication that we can navigate forward to a previously visited page //
        self.agwWebView.addObserver(self, forKeyPath: "canGoForward", options: .New, context: nil)
        
        // Observe when changes to canGoBack are made -- an indication that we can navigate to back to a previously visited page //
        self.agwWebView.addObserver(self, forKeyPath: "canGoBack", options: .New, context: nil)
    }
    
    func teardownWKWebViewKVO() {
        
        agwWebView.removeObserver(self, forKeyPath: "loading")
        agwWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        agwWebView.removeObserver(self, forKeyPath: "canGoForward")
        agwWebView.removeObserver(self, forKeyPath: "canGoBack")
    }
    
    
    // MARK: - Key Value Observer
    
    /// This message is sent to the receiver when the value at the specified key path relative to the given object has changed.
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "loading" { agwUpdateProgressIndicatorOnLoading(change!) }
        
        else if keyPath == "estimatedProgress" { agwUpdateProgressIndicatorOnEstimatedProgress(change!) }
        
        else if keyPath == "canGoForward" { agwUpdateUsabilityStateOfWebForwardButton(change!) }
        
        else if keyPath == "canGoBack" { agwUpdateUsabilityStateOfWebBackwardButton(change!) }
        
        else { super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context) }
    }
    
    
    // MARK: - Progress Bar Item Update Handlers
    
    /// Update our progress bar on change of web view loading state
    func agwUpdateProgressIndicatorOnLoading(change: [NSObject : AnyObject]) {
        
        let newValue = change[NSKeyValueChangeNewKey] as! NSNumber
        
        let isLoading = newValue.boolValue
        
        if (isLoading) {
            
            self.agwProgressView.layer.opacity = 1.0
        }
        else {
            
            // For effect we delay hidding the progress bar so that user can see it actually go to 100%
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.33 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                self.agwProgressView.layer.opacity = 0.0
                self.agwProgressView.setProgress(0.0, animated: false);
            }
        }
    }
    
    /// Update our progress bar on change of positive chage of estimated progress of web page load
    func agwUpdateProgressIndicatorOnEstimatedProgress(change: [NSObject : AnyObject]) {
        
        let newValue = change[NSKeyValueChangeNewKey] as! NSNumber
        let oldValue = change[NSKeyValueChangeOldKey] as! NSNumber
        
        
        // Check prevents the progress bar from animating backwards.
        
        let shouldAnimateChange = oldValue.floatValue > newValue.floatValue
        
        
        // Progress bar displays a minimum amount of progress to indicate activity.
        
        let displayValue: Float = fmaxf(self.minimumProgressValue, newValue.floatValue)
        
        self.agwProgressView.setProgress(displayValue, animated: shouldAnimateChange)
    }
    
    
    // MARK: - Navigation Items Update Handlers
    
    /// Update availability of forward browser button
    func agwUpdateUsabilityStateOfWebForwardButton(change: [NSObject : AnyObject]) {
        
        let newValue = change[NSKeyValueChangeNewKey] as! NSNumber
        let canGoForward = newValue.boolValue
        
        self.agwForwardButton.enabled = canGoForward
    }
    
    /// Update availability of forward browser button
    func agwUpdateUsabilityStateOfWebBackwardButton(change: [NSObject : AnyObject]) {
        
        let newValue = change[NSKeyValueChangeNewKey] as! NSNumber
        let canGoBackward = newValue.boolValue
        
        self.agwBackwardButton.enabled = canGoBackward
    }
    
    
    // MARK: - WK Navigation Delegate
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        let requestHost = navigationAction.request.URL?.host!
        
        if requestHost!.containsString(webPageRoot) {
            
            decisionHandler(.Allow)
        }
        else {
            
            // Prevent the user from navigating to an external site.
            
            decisionHandler(.Cancel)
            
            
            // Present alert to the user explaining why their action was canceled.
            
            let alert = UIAlertController(title: "Action Denied", message: "You are not permitted to navigate to an external website.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Ancillary 
    
    /// Disables the wab view forward and backward buttons.
    func disableForwardAndBackButtons() {
    
        self.agwForwardButton.enabled = false
        self.agwBackwardButton.enabled = false
    }
    
    /// Hide progress indicator
    func hideProgressIndicator() {
        
        self.agwProgressView.layer.opacity = 0.0
    }
}
