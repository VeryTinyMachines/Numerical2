//
//  URLHandler.swift
//  Numerical2
//
//  Created by Andrew Clark on 13/06/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class URLHandler {
    static let sharedHandler = URLHandler()
    private init () {}
    
    var url:URL?
    
    func questionFromURL() -> String? {
        
        if let url = url {
            print("")
            let urlString = url.absoluteString.replacingOccurrences(of: "numerical://", with: "")
            
            if urlString.contains("question=") {
                print("")
                // Process this question
                let rawString = urlString.replacingOccurrences(of: "question=", with: "").replacingOccurrences(of: "v", with: "^")
                
                if let decoded = rawString.removingPercentEncoding {
                    return decoded
                } else {
                    return rawString
                }
            }
        }
        
        return nil
    }
}
