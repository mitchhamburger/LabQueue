//
//  CASViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/15/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.


import Firebase

var globalNetId: String = ""

class CASViewController: UIViewController, UIWebViewDelegate {
    
    //@IBOutlet weak var myWebView: UIWebView!
        
    @IBOutlet weak var myWebView: UIWebView!
    //@IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        myWebView.delegate = self
        myWebView.scalesPageToFit = true
        
        //1. Load web site into my web view
        
        let myURL = NSURL(string: "https://awojak.mycpanel2.princeton.edu/333")
        let myURLRequest:NSURLRequest = NSURLRequest(URL: myURL!)
        myWebView.loadRequest(myURLRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //if (request.URLString == "https://awojak.mycpanel2.princeton.edu/333/index1.php") {
        if request.URL?.absoluteString.rangeOfString("https://awojak.mycpanel2.princeton.edu/333/index1.php") != nil {
            
            
            let startIndex = request.URL?.absoluteString.startIndex.advancedBy(57)
            let netId = request.URL?.absoluteString.substringFromIndex(startIndex!)
            globalNetId = netId!
            print(globalNetId)
            
            /*
            var urlString = "https://blistering-torch-3510.firebaseio.com/notifs/" + globalNetId
            var ref = Firebase(url:urlString)
            
 
            
            ref.observeEventType(.ChildAdded, withBlock: {snapshot in
                
                //for child in snapshot.children {
                
                let first = String(snapshot.value["first"] as! String)
                let last = String(snapshot.value["last"] as! String)
                let user = String(snapshot.value["user"] as! String)
                let type = String(snapshot.value["type"] as! String)
                
                var action = "buy"
                if (type.containsString("buy")) {action = "sell you"}
                
                UIApplication.sharedApplication().applicationIconBadgeNumber += 1
                let notification: UILocalNotification = UILocalNotification()
                notification.category = "FIRST_CATEGORY"
                //notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                
                
                notification.alertBody = "\(last) \(first) (\(user)) wants to \(action) a ticket!"
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                //UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                ref.removeValue()
                //}
            })*/
            
            self.performSegueWithIdentifier("UserLoggedIn", sender: netId)
            return false
        }
        return true
    }
    
}
