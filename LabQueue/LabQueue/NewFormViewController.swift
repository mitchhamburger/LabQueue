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
        let thisStudent: Student = Student(name: nameField.text!, helpMessage: problemField.text!, course: courseField.text!)
        allStudents.append(thisStudent)
        let jsonObj = ["Name": nameField.text!,
                       "NetID": "gc23",
                       "dicksdicksdicks":problemField.text!,
                       "Been Helped": false,
                       "dicksdicksdciksdc": false,
                       "In Queue": true,
                       "Request Time": "",
                       "Helped Time": "",
                       "Attending TA": "",
                       "Course": courseField.text!]
        let url: NSURL = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: .PrettyPrinted)
            
            // create post request
            let url = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            let semaphore = dispatch_semaphore_create(0)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    
                    print("Result -> \(result)")
                    
                } catch {
                    print("Error -> \(error)")
                }
                dispatch_semaphore_signal(semaphore)
            }
            task.resume()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
        } catch {
            print(error)
        }
    }
}