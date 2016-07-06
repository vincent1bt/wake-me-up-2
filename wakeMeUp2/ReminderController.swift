//
//  ReminderController.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/4/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import CoreData

protocol ReminderUpdatedProtocol {
    func updateReminder(reminder: NSManagedObject)
}

class ReminderController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    
    var reminder: NSManagedObject!
    var utils: Utils!
    var date: NSDate?
    var delegate: ReminderUpdatedProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.utils = Utils()
        if let date = reminder.valueForKey("date") as? NSDate {
            self.dateLabel.text = self.utils.dateToString(date)
            self.datePicker.date = date
        }
        self.textField.text = reminder.valueForKey("title") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func endEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func updateReminder() {
        if self.textField.text != self.reminder.valueForKey("title") as? String {
            self.reminder.setValue(self.textField.text, forKey: "title")
        }
        if self.date != nil {
            self.reminder.setValue(self.date!, forKey: "date")
        }
        self.delegate?.updateReminder(self.reminder)
    }
    
    @IBAction func getDate(sender: UIDatePicker) {
        self.date = sender.date
        self.dateLabel.text = self.utils.dateToString(sender.date)
    }

    @IBAction func createNotification(sender: UIBarButtonItem) {
        if self.date != nil || self.textField.text != nil {
            self.updateReminder()
        }
        self.performSegueWithIdentifier("backToremindersSegue", sender: self)
    }
}
