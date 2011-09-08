//
//  Lexer.h
//  Compiler
//
//  Created by Power Qian on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lexer : NSObject
{
    NSString *originText;
    NSMutableString *preProcessedText;
    NSMutableArray *result;
    NSArray *keyword;
}

@property (copy) NSString *originText;
@property (copy) NSMutableString *preProcessedText;
@property (retain) NSMutableArray *result;
@property (retain) NSArray *keyword;

- (void) loadText:(NSString *)text withKeyWordPath:(NSURL *)aPath;
- (void) preProcessor;
- (NSDictionary *) lexicalAnalyze:(unsigned long *)startFrom;

@end
