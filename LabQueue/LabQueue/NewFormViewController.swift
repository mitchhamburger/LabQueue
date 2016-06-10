//
//  NewFormViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
@IBDesignable

class NewFormViewController: UIViewController {

    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var problemField: UITextField!
    
    @IBOutlet weak var courseField: UITextField!
    
    
    @IBAction func submitForm(sender: UIButton) {
        /*submit POST request with name, problem, course, email, etc*/
        self.addToQueue()
        
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("StudentHomeViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
    
    func addToQueue() {
        let jsonObj = ["Name": "Dick Face",
                       "NetID": "gc23",
                       "Help Message":"I cant type",
                       "Been Helped": "True",
                       "Canceled": "False",
                       "In Queue": "False",
                       "Request Time": "7:25",
                       "Helped Time": "7:30",
                       "Attending TA": "Harry Heffernan",
                       "Course": "COS 217"]
        let url: NSURL = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: [])
        } catch {
            print(error)
            request.HTTPBody = nil
        }
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            // handle error
            guard error == nil
                else
            {
                return
            }
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            let json: NSDictionary?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            } catch let dataError {
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                // return or throw?
                return
            }
            
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                let success = parseJSON["success"] as? Int
                print("Succes: \(success)")
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
            
        })
        
        task.resume()
        
        
    }
}