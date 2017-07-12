//
//  Equation+CoreDataProperties.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import Foundation
import CoreData

extension Equation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Equation> {
        return NSFetchRequest<Equation>(entityName: "Equation");
    }

    @NSManaged public var question: String?
    @NSManaged public var answer: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var deviceIdentifier: String?
    @NSManaged public var identifier: String?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var sortOrder: NSNumber?
    @NSManaged public var posted: NSNumber?
    @NSManaged public var userDeleted: NSNumber?
}
