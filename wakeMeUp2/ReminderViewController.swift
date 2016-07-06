//
//  ViewController.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 6/26/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, APIWeatherProtocol, ReminderUpdatedProtocol, RemindersCellProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var degreesLabel: UILabel!
    var locationManager: CLLocationManager!
    var weatherApi: WeatherRequest!
    var reminderApi: Reminder!
    var reminders = [NSManagedObject]()
    var rowIndex: Int!
    var utils: Utils!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.weatherApi = WeatherRequest()
        self.weatherApi.delegate = self
        self.reminderApi = Reminder()
        self.utils = Utils()
        didFinishFetchReminders()
        configTable()
        configLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configLocation() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 5000
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.weatherApi.getWeather(newLocation)
    }
    
    func configTable() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reminders.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("remindersCell", forIndexPath: indexPath) as! ReminderCell
        let createCell: Bool = indexPath.row == reminders.count
        cell.delegate = self
        cell.createCell = createCell
        cell.accessoryType = createCell ? .None : .DetailButton
        cell.textField.tag = indexPath.row
        
        if createCell {
            cell.textField.text = ""
            cell.dateLabel.text = ""
            return cell
        }
        
        let reminder = self.reminders[indexPath.row]
        if let date = reminder.valueForKey("date") as? NSDate {
            cell.dateLabel.text = self.utils.dateToString(date)
        }
        cell.textField.text = reminder.valueForKey("title") as? String
        
        let finished = reminder.valueForKey("finished") as! Bool
        let color: UIColor = finished ? UIColor.init(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0) : UIColor.init(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        cell.textField.textColor = color
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRectMake(10, 7.5, tableView.frame.size.width, 20))
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.98)
        label.text = "Recordatorios"
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 35))
        view.addSubview(label)
        view.backgroundColor = UIColor.init(red: 236/255, green: 240/255, blue: 241/255, alpha: 0.98)
        return view
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.rowIndex = indexPath.row
        performSegueWithIdentifier("reminderSegue", sender: self)
    }
    
    @IBAction func beginEditReminder(sender: UITextField) {
        UIView.animateWithDuration(0.3) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0), atScrollPosition: .Bottom, animated: true)
            self.view.frame.origin.y = -115
        }
    }
    
    @IBAction func endEditReminder(sender: UITextField) {
        if sender.text != nil && sender.text != "" {
            if sender.tag == self.reminders.count {
                self.didFinishCreateReminder(sender.text!)
            } else {
                let reminder = self.reminders[sender.tag]
                if sender.text! == reminder.valueForKey("title") as! String {
                    UIView.animateWithDuration(0.2) {
                        self.view.frame.origin.y = 0
                    }
                    return
                }
                reminder.setValue(sender.text!, forKey: "title")
                self.reminderApi.updateReminder(reminder)
            }
            self.tableView.reloadData()
        }
        UIView.animateWithDuration(0.2) {
            self.view.frame.origin.y = 0
        }
    }
    
    func didFinishCreateReminder(title: String) {
        guard let reminder = self.reminderApi.createReminder(title) else {
            return
        }
        self.reminders.append(reminder)
        self.tableView.reloadData()
    }
    
    func didFinishFetchReminders() {
        guard let reminders = self.reminderApi.getReminders() else {
            return
        }
        self.reminders.appendContentsOf(reminders)
        self.tableView.reloadData()
    }
    
    func didRecieveAPIResults(weatherObject: Weather) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.dateLabel.text = weatherObject.date
            self.degreesLabel.text = weatherObject.degrees
            self.descriptionLabel.text = weatherObject.description
            if let imageIcon = weatherObject.icon {
                self.imageView.image = UIImage(named: imageIcon)
            }
        }
    }
    
    func updateReminder(reminder: NSManagedObject) {
        self.reminderApi.updateReminder(reminder)
        self.tableView.reloadData()
    }
    
    func completeReminderFromCell(id: Int) {
        let reminder = self.reminders[id]
        reminder.setValue(true, forKey: "finished")
        self.reminderApi.updateReminder(reminder)
        let index = NSIndexPath(forRow: id, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Fade)
    }
    
    func deleteReminderFromCell(id: Int) {
        let reminder = self.reminders[id]
        let index = NSIndexPath(forRow: id, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Left)
        self.reminderApi.deleteReminder(reminder)
        self.reminders.removeAtIndex(id)
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reminderSegue" {
            let view = segue.destinationViewController.childViewControllers.first as! ReminderController
            view.reminder = self.reminders[self.rowIndex]
        }
    }
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
    }
}

