//
//  Equation+CoreDataProperties.swift
//  NumericalDBDevProject
//
//  Created by Victor Hudson on 7/28/15.
//  Copyright © 2015 Victor Hudson. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Equation {

    @NSManaged var answer: String?
    @NSManaged var creationDate: Date?
    @NSManaged var deviceIdentifier: String?
    @NSManaged var identifier: String?
    @NSManaged var lastModifiedDate: Date?
//    @NSManaged var question: String?
    @NSManaged var sortOrder: NSNumber?
    @NSManaged var pad: Pad?

}
