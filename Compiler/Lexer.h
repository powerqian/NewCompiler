//
//  Lexer.h
//  Compiler
//
//  Created by Power Qian on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SymbolTable.h"

@interface Lexer : NSObject
{
    NSString *originText;
    NSMutableString *preProcessedText;
    NSMutableArray *result;
    NSArray *keyword;
//    SymbolTable *table1;
}

@property (copy) NSString *originText;
@property (copy) NSMutableString *preProcessedText;
@property (retain) NSMutableArray *result;
//@property (retain) SymbolTable *table1;

- (void) loadText;
- (void) preProcessor;
- (NSDictionary *) lexicalAnalyze:(unsigned long *)startFrom;

@end
