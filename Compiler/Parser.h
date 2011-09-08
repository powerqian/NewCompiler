//
//  Parser.h
//  Compiler
//
//  Created by Power Qian on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lexer.h"

@interface Parser : NSObject
{
    unsigned long sym;
    NSArray *lex;
    NSMutableArray *intermediateCode;
    NSMutableArray *constTable;
    NSMutableArray *commonTable;
    Lexer *lexer;
}

@property (retain) NSMutableArray *intermediateCode;
@property (retain) Lexer *lexer;
@property (assign) unsigned long sym;

//-(int) loadLex:(NSArray *)aLex;

-(NSString *) start;
-(NSString *) beginningOfTheProgram;
-(NSString *) parialProgram;
-(NSString *) constDeclaration;
-(NSDictionary *) constDefine;
-(NSString *) unsignedInt;
-(NSString *) variableDeclaration;
-(NSString *) identifier;
-(NSString *) statementPart;
-(NSArray *) complexStatement;
-(NSArray *) statement;
-(NSDictionary *) assignmentStatement;
-(NSString *) expression;
-(NSString *) item;
-(NSString *) factor;
-(NSString *) plusOperators;
-(NSString *) multiOperators;
-(NSArray *) conditionStatement;
-(NSArray *) loopStatement;
-(NSArray *) condition;
-(NSString *) compareOperations;

-(NSString *) newTemp;

-(void) error;
-(void) backpatch:(NSArray *)aList withValue:(NSNumber *)aValue;




@end
