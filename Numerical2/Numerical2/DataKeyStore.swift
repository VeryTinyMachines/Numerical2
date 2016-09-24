//
//  HowlDataKeyStore.swift
//  Midroll-iOS-App
//
//  Created by Andrew J Clark on 11/12/2015.
//  Copyright © 2015 Midroll. All rights reserved.
//

import Foundation

class DataKeyStore {

    var keys = [String: NSObject]()

    static let sharedStore = DataKeyStore()
    private init() {
    } //This prevents others from using the default '()' initializer for this class.
    
    func keyForEquation(equation: Equation) -> NSObject {
        if let stringKey = keyForEquationID(string: equation.identifier) {
            return keyForStringKey(stringKey: stringKey)
        }
        
        return keyForStringKey(stringKey: "null")
    }
    

    func keyForEquationID(string: String?) -> String? {
        if let string = string {
            return "equationID_\(string)"
        }
        
        return nil
    }
    
    
    func keyForStringKey(stringKey: String) -> NSObject {
        if let keyObject = keys[stringKey] {
            return keyObject
        } else {
            let newObject = NSObject()
            keys[stringKey] = newObject
            return newObject
        }
    }
}

