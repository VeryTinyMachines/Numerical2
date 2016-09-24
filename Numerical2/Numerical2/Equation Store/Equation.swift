//
//  Equation.swift
//  NumericalDBDevProject
//
//  Created by Victor Hudson on 7/15/15.
//  Copyright © 2015 Victor Hudson. All rights reserved.
//

import Foundation
import CoreData

// TODO: See if the Xcode 7/Swift 2.0 bug for the below comment is fixed
//@objc(Equation)
open class Equation: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
	override open func awakeFromInsert() {
		super.awakeFromInsert()
		self.creationDate = Date()
		self.identifier = UUID().uuidString
		self.updateEquationStats()
	}
	
	let questionKey = "question"
	open var question:String?	{
		set {
			self.willChangeValue(forKey: questionKey)
			self.setPrimitiveValue(newValue, forKey:questionKey)
			self.didChangeValue(forKey: questionKey)
			self.updateEquationStats()
		}
		get {
			self.willAccessValue(forKey: questionKey)
			let question = self.primitiveValue(forKey: questionKey) as? String
			self.didAccessValue(forKey: questionKey)
			return question
		}
	}
	
	fileprivate func updateEquationStats () {
		let device = currentDevice()
		let date = Date()
		self.lastModifiedDate = date
		self.deviceIdentifier = device
		self.pad?.lastModifiedDate =  date
		self.pad?.deviceIdentifier = deviceIdentifier
	}
}
