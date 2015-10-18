//
//  OpenEarsWrapper.m
//  Numerical2
//
//  Created by Kevin Enax on 10/11/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

#import "OpenEarsWrapper.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEEventsObserver.h>

@interface OpenEarsWrapper ()<OEEventsObserverDelegate>

@property (nonatomic, readonly) NSString *openEarsLanguageModelPath;
@property (nonatomic, readonly) NSString *openEarsDictionaryModelPath;
@property (nonatomic, readonly) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, readonly, weak) NSObject<DictationDelegate> *delegate;

@end

@implementation OpenEarsWrapper

static NSString *OEFileName = @"OEFiles";
#define OEAcousticModelEnglish ([OEAcousticModel pathToModel:@"AcousticModelEnglish"])

- (instancetype)init {
    self = [super init];
    [self generateOpenEarsModels];
    
    [[OEPocketsphinxController sharedInstance] setActive:YES error:nil];
    _openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];

    return self;
}

- (void)dealloc {
    [[OEPocketsphinxController sharedInstance] stopListening];
    [[OEPocketsphinxController sharedInstance] setActive:NO error:nil];
}

#pragma mark - OpenEarsEventObserver methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    [self.delegate didDictateText:hypothesis];
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (void)generateOpenEarsModels {
    
    NSDictionary *dictionaryDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Dictionary_English" ofType:@"plist"]];
    NSMutableArray *wordsAndPhrases = @[].mutableCopy;
    
    [dictionaryDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *value, BOOL * _Nonnull stop) {
        [wordsAndPhrases addObjectsFromArray:value];
    }];
    
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    NSError *error = [lmGenerator generateLanguageModelFromArray:wordsAndPhrases withFilesNamed:OEFileName forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error == nil) {
        
        _openEarsLanguageModelPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:OEFileName];
        _openEarsDictionaryModelPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:OEFileName];
        
    } else {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
}
- (void)startListeningWithDelegate:(id<DictationDelegate>)delegate {
    _delegate = delegate;
    [[OEPocketsphinxController sharedInstance] setActive:YES error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.openEarsLanguageModelPath dictionaryAtPath:self.openEarsDictionaryModelPath acousticModelAtPath:OEAcousticModelEnglish languageModelIsJSGF:NO];
}

- (void)stopListening {
    [[OEPocketsphinxController sharedInstance] stopListening];
}

@end
