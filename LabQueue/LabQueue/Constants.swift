//
//  Constants.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/27/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//
//  Keys for NSNotificationCenter
//
import UIKit
import CoreData
import Alamofire

let removeStudentFromQueue = "com.mitchhamburger.removeStudentFromQueue"
let addStudentToQueue = "com.mitchhamburger.addStudentToQueue"
let match = "com.mitchhamburger.match"
let firstRowSelect = "com.mitchhamburger.firstrowselect"
let secondRowSelect = "com.mitchhamburger.secondrowselect"
let thirdRowSelect = "com.mitchhamburger.thirdrowselect"


let hostName = "https://tempwebservice-mh20.c9users.io"

/// get a token representing core data's version of the queue, to be compared with the remote database's version
func getSyncToken() -> String {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
    
    let fetchRequest = NSFetchRequest()
    let sectionSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
    let sortDescriptors = [sectionSortDescriptor]
    fetchRequest.entity = studentEntity
    fetchRequest.sortDescriptors = sortDescriptors
    
    var hashString: String = ""
    var count: Int = 0
    do {
        let result = try managedContext?.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        for entry in result {
            count += 1
            hashString += entry.valueForKey("netid") as! String
        }
    } catch {
        print("error fetching")
    }
    hashString += ",\(count)"
    return hashString
}

/// Check whether the requests in Core Data are in sync with the requests in the remote database
/// returns true if yes, false if no
func checkSync() -> Bool {
    /*Check Sync*/
    let token = getSyncToken()
    let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/Sync")!
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
    let jsonObj = ["Sync Token": token]
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
    do {
        let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: .PrettyPrinted)
        // insert json data to the request
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonData
    } catch {
        print("error converting input to json")
    }
    
    let semaphore = dispatch_semaphore_create(0)
    var test: Bool = true
    let task = session.dataTaskWithRequest(request) {
        (let data, let response, let error) in
        if data != nil {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                if json["Response"] as! String == "Out of Sync" {
                    test = false
                }
            } catch {
                print("error converting to json")
            }
        }
        dispatch_semaphore_signal(semaphore)
    }
    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    return test
}

/// Sync the requests in Core Data to the remote data base through the API
/// returns number of students in the active queue
func syncQueue() -> Int{
    
    /*1. first delete everything from core data*/
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
    
    // Initialize Fetch Request
    let fetchRequest = NSFetchRequest()
    
    // Configure Fetch Request
    fetchRequest.entity = studentEntity
    
    
    do {
        let result = try managedContext!.executeFetchRequest(fetchRequest)
        for student in result {
            let studentobj = student as! NSManagedObject
            managedContext?.deleteObject(studentobj)
        }
    } catch {
        let fetchError = error as NSError
        print(fetchError)
    }
    
    do {
        try managedContext?.save()
    } catch {
        print("error saving")
    }
    
    
    /* 2. Then save database queue to an array of students*/
    var activeQueue = [Student]()
    let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/Requests")!
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
    
    let semaphore = dispatch_semaphore_create(0)
    let task = session.dataTaskWithRequest(request) {
        (
        let data, let response, let error) in
        if error == nil && data != nil {
            do {
                // Convert NSData to Dictionary where keys are of type String, and values are of any type
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                for student in (json["Queue"]! as! NSArray) {
                    let thisStudent: Student = Student(name: student["Name"] as! String, helpMessage: student["Help Message"] as! String, course: student["Course"] as! String, netid: student["NetID"] as! String, requestID: student["RequestID"] as! Int)
                    activeQueue.append(thisStudent)
                }
                
            } catch {
                "error with json serialization"
            }
        }
        dispatch_semaphore_signal(semaphore)
    }
    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    
    /*3. Finally load activeQueue into core data*/
    var count = 0
    for tempStudent in activeQueue {
        count += 1
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(tempStudent.name, forKey: "name")
        inputStudentObj.setValue(tempStudent.helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(tempStudent.course, forKey: "course")
        inputStudentObj.setValue(tempStudent.netID, forKey: "netid")
        inputStudentObj.setValue(tempStudent.requestID, forKey: "requestid")
        do {
            try managedContext!.save()
        } catch {
            print("error witth \(tempStudent.netID)")
        }
    }
    return count
}

/// return sha256 hash of string
func sha256(str: String) -> String? {
    guard
        let data = str.dataUsingEncoding(NSUTF8StringEncoding),
        let shaData = sha256(data)
        else { return nil }
    let rc = shaData.base64EncodedStringWithOptions([])
    return rc
}

/// return sha256 hash of data
func sha256(data: NSData) -> NSData? {
    guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
    CC_SHA256(data.bytes, CC_LONG(data.length), UnsafeMutablePointer(res.mutableBytes))
    return res
}

/// get appropriate WSSE headers
func getWSSEHeaders() -> [String : String] {
    let username = "mh20"
    let secret_key = "464f7aa98c61699a2c5682dd518d54e9"
    let temp = NSUUID().UUIDString
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    let timestring = dateFormatter.stringFromDate(NSDate())
    let nonce = temp.stringByReplacingOccurrencesOfString("-", withString: "")
    let digest = sha256(nonce + timestring + secret_key)
    
    let headers: [String:String] = [
        "Authorization": "WSSE profile=\"UsernameToken\"",
        "X-WSSE": "UsernameToken Username=\"\(username)\", PasswordDigest=\"\(digest!)\", Nonce=\"\(nonce)\", Created=\"\(timestring)\""
    ]
    return headers
}

func getTAInfo(netid: String) -> [String: AnyObject]{
    var taInfo: [String: AnyObject] = [:]
    
    let url: NSURL = NSURL(string: "https://tigerbook-sandbox.herokuapp.com/api/v1/undergraduates/\(netid)")!
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url)
    let headers = getWSSEHeaders()
    request.allHTTPHeaderFields = headers
    request.HTTPMethod = "GET"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
    
    let semaphore = dispatch_semaphore_create(0)
    let task = session.dataTaskWithRequest(request) {
        (
        let data, let response, let error) in
        if error == nil && data != nil {
            do {
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                taInfo = ["Class Year": jsonObj["class_year"] as! Int, "Name": jsonObj["full_name"] as! String]
            } catch {
                taInfo = ["Class Year": 0, "Name": ""]
            }
        }
        dispatch_semaphore_signal(semaphore)
    }
    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    return taInfo
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}


