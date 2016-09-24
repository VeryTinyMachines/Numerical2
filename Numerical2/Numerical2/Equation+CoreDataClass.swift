//
//  Equation+CoreDataClass.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

public class Equation: NSManagedObject {

    func isEqualToCKEquation(record: CKRecord) -> Bool {
        
        // If the answer, the question, the modifiedDate, etc is all equal then it is up to date.
        
        if answer == record.object(forKey: "answer") as? String && question == record.object(forKey: "question") as? String && lastModifiedDate == record.object(forKey: "equationLastModifiedDate") as? NSDate && sortOrder == record.object(forKey: "sortOrder") as? NSNumber {
            
            return true
        }
        
        return false
    }
    
    func updateTo(record: CKRecord) {
        print("updateTo")
        
        answer = record.object(forKey: "answer") as? String
        question = record.object(forKey: "question") as? String
        creationDate = record.object(forKey: "equationCreationDate") as? NSDate
        deviceIdentifier = record.object(forKey: "deviceIdentifier") as? String
        identifier = record.object(forKey: "identifier") as? String
        lastModifiedDate = record.object(forKey: "equationLastModifiedDate") as? NSDate
        sortOrder = record.object(forKey: "sortOrder") as? NSNumber
        posted = NSNumber(value: true)
        
        
        print(lastModifiedDate)
    }
}
