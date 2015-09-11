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
public class Equation: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
	override public func awakeFromInsert() {
		super.awakeFromInsert()
		self.creationDate = NSDate()
		self.identifier = NSUUID().UUIDString
		self.updateEquationStats()
	}
	
	let questionKey = "question"
	public var question:String?	{
		set {
			self.willChangeValueForKey(questionKey)
			self.setPrimitiveValue(newValue, forKey:questionKey)
			self.didChangeValueForKey(questionKey)
			self.updateEquationStats()
		}
		get {
			self.willAccessValueForKey(questionKey)
			let question = self.primitiveValueForKey(questionKey) as? String
			self.didAccessValueForKey(questionKey)
			return question
		}
	}
	
	private func updateEquationStats () {
		let device = currentDevice()
		let date = NSDate()
		self.lastModifiedDate = date
		self.deviceIdentifier = device
		self.pad?.lastModifiedDate =  date
		self.pad?.deviceIdentifier = deviceIdentifier
	}
}
