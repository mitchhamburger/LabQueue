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

let removeStudentFromQueue = "com.mitchhamburger.removeStudentFromQueue"
let addStudentToQueue = "com.mitchhamburger.addStudentToQueue"
let hostName = "https://tempwebservice-mh20.c9users.io"

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
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
            if json["Response"] as! String == "Out of Sync" {
                test = false
            }
        } catch {
            print("error converting to json")
        }
        dispatch_semaphore_signal(semaphore)
    }
    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    return test
}

func syncQueue() {
    
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
                    let thisStudent: Student = Student(name: student["Name"] as! String, helpMessage: student["Help Message"] as! String, course: student["Course"] as! String, netid: student["NetID"] as! String)
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
    for tempStudent in activeQueue {
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(tempStudent.name, forKey: "name")
        inputStudentObj.setValue(tempStudent.helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(tempStudent.course, forKey: "course")
        inputStudentObj.setValue(tempStudent.netID, forKey: "netid")
        do {
            try managedContext!.save()
        } catch {
            print("error witth \(tempStudent.netID)")
        }
    }
}