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