//
//  TAPostReportViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 8/2/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import SCLAlertView

class TAPostReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var surveyTable: UITableView!
    var json: [String: [[String: AnyObject]]] = [:]
    var controllers: [SSRadioButtonsController]?
    var createdCells: [Bool]?
    var requestName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("PostReportQuestions", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: [[String: AnyObject]]]
        } catch {
            print("error getting json")
        }

        surveyTable.dataSource = self
        surveyTable.delegate = self
        surveyTable.rowHeight = UITableViewAutomaticDimension
        surveyTable.estimatedRowHeight = 140
        surveyTable.tableFooterView = UIView()
        
        createdCells = [Bool](count: json["questions"]!.count, repeatedValue: false)
        controllers = [SSRadioButtonsController](count: json["questions"]!.count, repeatedValue: SSRadioButtonsController())
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.title = "Post Report: \(requestName!)"
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (json["questions"]?.count)!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //at least 110
        let count = (json["questions"]![indexPath.row]["options"] as! NSArray).count
        if count > 2 {
            return CGFloat(110 + (count - 2) * 30)
        }
        return 110
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = surveyTable.dequeueReusableCellWithIdentifier("postreportcell") as! TAPostReportQuestionCell
        
        let style = NSMutableParagraphStyle()
        //style.lineSpacing = 1
        let attributes = [NSParagraphStyleAttributeName : style]
        cell.questionLabel.attributedText = NSAttributedString(string: (json["questions"]![indexPath.row]["q"] as? String)!, attributes:attributes)
        
        cell.question = json["questions"]![indexPath.row]
        let options = cell.setup()
        
        
        if !createdCells![indexPath.row] {
            cell.radioController.setButtonsArray(options)
            cell.radioController.shouldLetDeSelect = false
            controllers![indexPath.row] = cell.radioController
            
            createdCells![indexPath.row] = true
        }
        
        else {
            for button in options {
                controllers![indexPath.row].addButton(button)
            }
        }
        
        return cell
    }
    @IBAction func submitPressed(sender: UIButton) {
        var report: [String: String] = [:]
        for i in 0...surveyTable.numberOfRowsInSection(0) - 1 {
            let cell = surveyTable.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! TAPostReportQuestionCell
            //report["Question \(i + 1)"] = cell.radioController.selectedButton()?.titleLabel?.text!
            report[json["questions"]![i]["q"] as! String] = cell.radioController.selectedButton()?.titleLabel?.text!
        }
        
        if report.count != surveyTable.numberOfRowsInSection(0) {
            SCLAlertView().showInfo("Survey Incomplete", subTitle: "Please fill out all of the questions and press Submit")
        }
        else {
            let vc = self.navigationController?.viewControllers[1]
            self.navigationController?.popToViewController(vc!, animated: true)
            print(report)
        }
    }
}
