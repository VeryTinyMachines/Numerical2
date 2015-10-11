//
//  OpenEarsWrapper.h
//  Numerical2
//
//  Created by Kevin Enax on 10/11/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DictationDelegate <NSObject>

-(void)didDictateText:(NSString *)text;

@end

@interface OpenEarsWrapper : NSObject

- (void)startListeningWithDelegate:(id<DictationDelegate>)delegate;
- (void)stopListening;

@end
