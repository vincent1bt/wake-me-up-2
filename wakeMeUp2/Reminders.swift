//
//  Reminders.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/4/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import CoreData
import UIKit


struct Reminder {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func createReminder(title: String) -> NSManagedObject? {
        let managedContext = self.appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: managedContext)
        let reminder = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        reminder.setValue(title, forKey: "title")
        reminder.setValue(false, forKey: "finished")
        reminder.setValue(true, forKey: "editing")
        
        do {
            try managedContext.save()
            return reminder
        } catch let error as NSError {
            print("Could not save \(error.userInfo)")
            return nil
        }
    }
    
    func getReminders() -> [NSManagedObject]? {
        let managedContext = self.appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Reminder")
        
        do {
            let reminders = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            return reminders
        } catch let error as NSError {
            print("Could not fetch \(error.userInfo)")
            return nil
        }
    }
    
    func deleteReminder(reminder: NSManagedObject) {
        let managedContext = self.appDelegate.managedObjectContext
        managedContext.deleteObject(reminder)
    }
    
    func updateReminder(reminder: NSManagedObject) {
        do {
            try reminder.managedObjectContext?.save()
        } catch let error as NSError {
            print("Could not update \(error.userInfo)")
        }
    }
}



