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
            let prefs = NSUserDefaults.standardUserDefaults()
            let startIndex = request.URL?.absoluteString.startIndex.advancedBy(57)
            let netId = request.URL?.absoluteString.substringFromIndex(startIndex!)
            globalNetId = netId!
            prefs.setValue(netId!, forKey: "UserNetID")
            registerForPushNotifications(UIApplication.sharedApplication())
            syncQueue()
            if (verify(netId!) == "Student") {
                self.performSegueWithIdentifier("StudentLoggedIn", sender: netId)
                return false
            }
            else if (verify(netId!) == "TA") {
                self.performSegueWithIdentifier("TALoggedIn", sender: netId)
                return false
            }
            print(globalNetId)
          
        }
        return true
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        //registerToken(userDeviceToken, netid: globalNetId)
    }
}

/// Check whether a NetID belongs to a student or a TA through the API
///
/// args:
/// * netid: NetID of student
///
/// returns "Student" for student and "LabTA" for TA
func verify(netid: String) -> String {
    let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(netid)/Verify")!
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
    var studentType: String = ""
    let semaphore = dispatch_semaphore_create(0)
    let task = session.dataTaskWithRequest(request) {
        (
        let data, let response, let error) in
        guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
            print("error")
            return
        }
        if error == nil && data != nil {
            studentType = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        }
        dispatch_semaphore_signal(semaphore)
    }
    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    return studentType
}
