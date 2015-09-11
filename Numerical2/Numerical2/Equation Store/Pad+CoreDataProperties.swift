//
//  Pad+CoreDataProperties.swift
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

extension Pad {

    @NSManaged var creationDate: NSDate?
    @NSManaged var identifier: String?
    @NSManaged var lastModifiedDate: NSDate?
    @NSManaged var name: String?
    @NSManaged var removable: NSNumber?
    @NSManaged var deviceIdentifier: String?
    @NSManaged var equations: NSSet?

}
