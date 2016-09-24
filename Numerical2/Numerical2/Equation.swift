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


public struct EquationNotification {
    public static let updated = "EquationNotification.updated"
}

public struct EquationCodingKey {
    public static let answer = "answer"
    public static let creationDate = "creationDate"
    public static let deviceIdentifier = "deviceIdentifier"
    public static let identifier = "identifier"
    public static let lastModifiedDate = "lastModifiedDate"
    public static let question = "question"
}



class Equation : NSObject, NSCoding {

    var answer: String? {
        didSet {
            self.postChangeNotification()
            DispatchQueue.main.async {
                EquationStore.sharedStore.save()
            }
        }
    }
    
    var creationDate: Date?
    var deviceIdentifier: String?
    var identifier: String?
    var lastModifiedDate: Date?
    var question: String? {
        didSet {
            self.postChangeNotification()
            DispatchQueue.main.async {
                EquationStore.sharedStore.save()
            }
        }
    }
    
    var sortOrder: NSNumber?
//    var padID: String?
    
    override public var description: String {
        
        var question = ""
        var answer = ""
        
        if let theQuestion = self.question {
            question = theQuestion
        }
        
        if let theAnswer = self.answer {
            answer = theAnswer
        }
        
        return "\(question)=\(answer)"
    }
    
    public static func ==(left: Equation, right: Equation) -> Bool {
        return left.question == right.question
    }
    
    override public var hashValue: Int {
        if let question = question {
            return question.hashValue
        }
        
        return 0
    }
    
    func postChangeNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: EquationNotification.updated), object: DataKeyStore.sharedStore.keyForEquation(equation: self))
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.answer, forKey: EquationCodingKey.answer)
        
        aCoder.encode(self.creationDate, forKey: EquationCodingKey.creationDate)
        
        aCoder.encode(self.deviceIdentifier, forKey: EquationCodingKey.deviceIdentifier)
        
        aCoder.encode(self.identifier, forKey: EquationCodingKey.identifier)
        
        aCoder.encode(self.lastModifiedDate, forKey: EquationCodingKey.lastModifiedDate)
        
        aCoder.encode(self.question, forKey: EquationCodingKey.question)
        
        
    }
    
    override init() {
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let obj = aDecoder.decodeObject(forKey: EquationCodingKey.answer) as? String {
            self.answer = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: EquationCodingKey.creationDate) as? Date {
            self.creationDate = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: EquationCodingKey.deviceIdentifier) as? String {
            self.deviceIdentifier = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: EquationCodingKey.identifier) as? String {
            self.identifier = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: EquationCodingKey.lastModifiedDate) as? Date {
            self.lastModifiedDate = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: EquationCodingKey.question) as? String {
            self.question = obj
        }
    }
    
    
    
}
