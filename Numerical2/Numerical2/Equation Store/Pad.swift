//
//  Pad.swift
//  NumericalDBDevProject
//
//  Created by Victor Hudson on 7/15/15.
//  Copyright © 2015 Victor Hudson. All rights reserved.
//

import Foundation
import CoreData

// TODO: See if the Xcode 7/Swift 2.0 bug for the below comment is fixed
//@objc(Pad)
open class Pad: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
	override open func awakeFromInsert() {
		super.awakeFromInsert()
		print(#function)
		let date = Date()
		self.creationDate = date
		self.lastModifiedDate = date
		self.identifier = UUID().uuidString
	}
}
