//
//  SoundManager.swift
//  Numerical2
//
//  Created by Andrew Clark on 3/11/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import AudioToolbox

public enum SoundType {
    case click
    case clear
    case restore
}

class SoundManager {
    
    static let sharedStore = SoundManager()
    fileprivate init() {}
    
    var clickSoundID: SystemSoundID = 0
    var clearSoundID: SystemSoundID = 0
    var restoreSoundID: SystemSoundID = 0
    
    func playSound(sound: SoundType) {
        
        switch sound {
        case .click:
            if clickSoundID == 0 {
                primeSound(sound: sound)
            }
            AudioServicesPlaySystemSound(clickSoundID)
        
        case .clear:
            if clearSoundID == 0 {
                primeSound(sound: sound)
            }
            AudioServicesPlaySystemSound(clearSoundID)
        case .restore:
            if restoreSoundID == 0 {
                primeSound(sound: sound)
            }
            AudioServicesPlaySystemSound(restoreSoundID)
        }
    }
    
    func primeSound(sound: SoundType) {
        switch sound {
        case .click:
            if let soundURL = Bundle.main.url(forResource: "simple", withExtension: "aiff") {
                AudioServicesCreateSystemSoundID(soundURL as CFURL, &clickSoundID)
            }
        case .clear:
            if let soundURL = Bundle.main.url(forResource: "professional", withExtension: "aiff") {
                AudioServicesCreateSystemSoundID(soundURL as CFURL, &clearSoundID)
            }
        case .restore:
            if let soundURL = Bundle.main.url(forResource: "professional-reverse", withExtension: "aiff") {
                AudioServicesCreateSystemSoundID(soundURL as CFURL, &restoreSoundID)
            }
        }
    }
    
    class func primeSounds() {
        for sound in [SoundType.click, SoundType.clear, SoundType.restore] {
            SoundManager.sharedStore.primeSound(sound: sound)
        }
    }
    
    class func playSound(sound: SoundType) {
        SoundManager.sharedStore.playSound(sound: sound)
    }
}
