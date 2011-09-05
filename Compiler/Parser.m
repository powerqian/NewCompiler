//
//  Parser.m
//  Compiler
//
//  Created by Power Qian on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define OK 1
#define ERROR 0

#define kSuccess @"Success"
#define kFail @"Fail"
#define kDone @"Done"


#import "Parser.h"

@implementation Parser
{
    int i;
}

@synthesize intermediateCode;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sym = 0;
        lex = [[NSArray alloc] init];
//        table = [[SymbolTable alloc] init];
        constTable = [NSMutableArray arrayWithCapacity:1024];
        commonTable = [NSMutableArray arrayWithCapacity:1024];
        intermediateCode = [NSMutableArray arrayWithCapacity:1024];
        lexer = [[Lexer alloc] init];
        i = 0;
    }
    
    return self;
}

-(void) backpatch:(NSArray *)aList withValue:(NSString *)aValue
{
    for ( NSNumber *aNum in aList ) {
        
        NSMutableString *stringToBackpatch = [intermediateCode objectAtIndex:[aNum unsignedLongValue]];
        [stringToBackpatch replaceCharactersInRange:[stringToBackpatch rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] 
                                                                                       options:NSBackwardsSearch]
                                         withString:aValue]; 
    }
   
}

-(NSString *) newTemp
{
    ++i;
    return [NSString stringWithFormat:@"T%d",i];
}

////-(int) loadLex:(NSArray *)aLex
//{
//    lex = [NSArray arrayWithArray:aLex];
//    return OK;
//}

-(NSString *) start
{
    [lexer loadText];
    [lexer preProcessor];
    NSLog(@"Start parser program");
    
    NSString *beginningOfTheProgram = [self beginningOfTheProgram];
    if ( [beginningOfTheProgram isEqualToString:kSuccess] ) {
        
        NSString *parialProgram = [self parialProgram];
        if ( [parialProgram isEqualToString:kSuccess] ) {
            return kSuccess;
        }
        else return kFail;
    }
    else return kFail;    
}

-(NSString *) beginningOfTheProgram
{
    unsigned long currentSym = sym;    
        
    if ( [[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$PROGRAM"] ) {
        NSLog(@"Parser Effected");
        ++sym;
        
        if ( [[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$ID"] ) {
            NSLog(@"Parser Effected");;
            ++sym;
        }
        else { sym = currentSym; return kFail; }
        //
        //
        //
        return kSuccess;
    }
    else { sym = currentSym; return kFail; }
        
}

-(NSString *) parialProgram
{
    NSString *constDeclaration = [self constDeclaration];
    if ( constDeclaration != nil ) {
        //
        //
    }
    
    NSString *variableDeclaration = [self variableDeclaration];
    if ( variableDeclaration != nil ) {
        //
        //
    }
    
    NSString *statementPart = [self statementPart];
    if ( statementPart != nil ){
        //
        //
        //
        return kSuccess;
    }
    else return kFail;
}

-(NSString *) constDeclaration
{
    unsigned long currentSym = sym;
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$CONST"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
        NSDictionary *constDefine = [self constDefine];
        if ( constDefine != nil ) {
            
            [constTable addObject:constDefine];
            
            //产生中间代码
            NSMutableString *ic = [NSString stringWithFormat:@"%@ = %@",
                            [[constDefine allKeys] lastObject],[[constDefine allValues] lastObject]];
            [intermediateCode addObject:ic];
            NSLog(@"Generated an intermediate code:%@",ic);
            //
            
            while ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$COMMAR"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                constDefine = [self constDefine];
                if ( constDefine != nil ) {
                    [constTable addObject:constDefine];
                    
                    //产生中间代码
                    NSMutableString *ic = [NSString stringWithFormat:@"%@ = %@",
                                    [[constDefine allKeys] lastObject],[[constDefine allValues] lastObject]];
                    [intermediateCode addObject:ic];
                    NSLog(@"Generated an intermediate code:%@",ic);
                    //
                }//if
                else { sym = currentSym; return nil; }
            }//while
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$SEMICOLON"]) {
                return kSuccess;
            }
            else { sym = currentSym; return nil; }
        }//if
        else { sym = currentSym; return nil; }
    }//if
    else { sym = currentSym; return nil; }
}

-(NSDictionary *) constDefine
{
    unsigned long currentSym = sym;
    NSString *value;
    NSString *identifier = [self identifier];
    if ( identifier != nil ) {
        
        if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$EQUAL"]) {
            NSLog(@"Parser Effected");;
            ++sym;
            
            value = [self unsignedInt];
            
            if (value != nil) {
                
////                [table setDetailForObject:identifier value:[NSString stringWithString:value]];  //填符号
//                
////                NSMutableString *ic = [NSString stringWithFormat:@"%@ = %@",identifier,value];//产生中间代码                
//                NSLog(@"Generating an intermediate code:%@",ic);
//                [intermediateCode addObject:ic];
                
                return [NSDictionary dictionaryWithObject:value forKey:identifier];
            }
            else { currentSym = sym; return nil; }
        }
        else { currentSym = sym; return nil; }
    }
    else { sym = currentSym; return nil; }
}

-(NSString *) unsignedInt
{
    NSString *returnValue;
    NSDictionary *lexerResult = [lexer lexicalAnalyze:&sym];
    if ( [[[lexerResult allKeys] lastObject] isEqualToString:@"$INT"] ){
        NSLog(@"Parser Effected");;
        
        returnValue = [[lexerResult allValues] lastObject];
        ++sym;
        
//        while ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$COMMAR"]) {
//            NSLog(@"Parser Effected");;
//            ++sym;
//            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$INT"]){
//                //
//                //
//            }
//            else return ERROR;
//        }
        
        return returnValue;
    }
    else return nil;
}

-(NSString *) variableDeclaration
{
    unsigned long currentSym = sym;
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$VAR"]) {
        NSLog(@"Parser Effected");;    
        ++sym;
        
        NSString *identifier = [self identifier];
        if ( identifier != nil ) {
            
            [commonTable addObject:[NSDictionary dictionaryWithObject:@"" forKey:identifier]];//添加到符号表
            
            while ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$COMMAR"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                
                identifier = [self identifier];
                if ( identifier != nil ) {
                    [commonTable addObject:[NSDictionary dictionaryWithObject:@"" forKey:identifier]];//添加到符号表
                }
                else return nil;
                
            }
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$SEMICOLON"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                //
                //
            }
            else { sym = currentSym; return nil; }
            
        }
        else { sym = currentSym; return nil; }
        
        return kSuccess;
    }
    else return nil;
}

-(NSString *) identifier
{
    unsigned long currentSym = sym;
    
    NSDictionary *result = [lexer lexicalAnalyze:&sym];
    if ( [[[result allKeys] lastObject] isEqualToString:@"$ID"]) {
        NSLog(@"Parser Effected");;
        
        NSString *returnValue = [[result allValues] lastObject];
        
        ++sym;
        
        
        return returnValue;
    }
    else { sym = currentSym; return nil; }
}

-(NSString *) statementPart
{
//    unsigned long currentSym = sym;
    NSArray *statement = [self statement];
    if ( statement != nil ) {
        //
        //
        //
         return kSuccess;
    }
    else {
//        sym = tempSym;
        NSArray *complexStatement = [self complexStatement];
        if ( complexStatement != nil ) {
            //
            //
            //
            return kSuccess;
        }
        else return nil;
    }
}

-(NSArray *) complexStatement
{
    NSArray *nextlist = [NSArray array];
    unsigned long currentSym = sym;
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$BEGIN"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
        NSArray *statement1 = [self statement];
        
        if ( statement1 != nil ){
            
            while ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$SEMICOLON"]){
                NSLog(@"Parser Effected");;
                ++sym;
                
                NSString *Mquad = [NSString stringWithFormat:@"%lu",[intermediateCode count]];
                
                NSArray *statement2 = [self statement];
                if( statement2 != nil ){
                    [self backpatch:statement1 withValue:Mquad];
                    nextlist = statement2;
                }
                else { sym = currentSym; return nil; }
            }
        }
        else { sym = currentSym; return nil; }
        
        if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$END"]) {
            NSLog(@"Parser Effected");;
            ++sym;
            
            return nextlist;
        }
        else { sym = currentSym; return nil; }
        
    }
    else { sym = currentSym; return nil; }
}

-(NSArray *) statement
{
    unsigned long currentSym = sym;
    NSArray *nextlist = [NSArray array];
    NSDictionary *assignmentStatement = [self assignmentStatement];
    
    if ( assignmentStatement != nil  ) {
      
        NSMutableString *ic = [NSString stringWithFormat:@":=,%@,-,%@",
                        [[assignmentStatement allValues] lastObject],[[assignmentStatement allKeys] lastObject]];
        [intermediateCode addObject:ic];
        NSLog(@"%@",ic);        
        //
        //
        return nextlist;
    }//赋值语句
    else {
        NSArray *conditionStatement = [self conditionStatement];
        if ( conditionStatement != nil ) {
            [nextlist arrayByAddingObjectsFromArray:conditionStatement];
            return nextlist;
        }//条件语句
        else {
            NSArray *loopStatement = [self loopStatement];
            if ( loopStatement != nil ) {
                //
                //
//                [nextlist arrayByAddingObjectsFromArray:loopStatement];
                nextlist = [loopStatement lastObject];
                return nextlist;
            }//循环
            else {
                NSArray *complexStatement = [self complexStatement];
                if ( complexStatement != nil ) {
                    nextlist = complexStatement;
                    return nextlist;
                }//复合
//                if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$END"]) {
//                    NSLog(@"Parser Effected");;
//                    return nextlist;
//                }// 空语句
                else {
                    unsigned long newCurrentSym = sym;
                    if ( [[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$END"] ) {
                        sym = newCurrentSym;
                        return nextlist;
                    }
                    else { sym = currentSym; return nil; }
                }
            }
        }
    }
}//语句

-(NSDictionary *) assignmentStatement
{
    unsigned long currentSym = sym;
    NSString *identifier = [self identifier];
    if ( identifier != nil ) {
        if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$ASSIGN"]) {
            NSLog(@"Parser Effected");;
            ++sym;
            
            NSString *expression = [self expression];
            if( expression != nil ){
                //
                //
                return [NSDictionary dictionaryWithObject:expression forKey:identifier];
            }
            else { sym = currentSym; return nil; }
        }//IF ASSIGN
        else return nil;
    }//IF identifier
    else return nil;
}//赋值语句

-(NSString *) expression
{
    NSString *returnValue;
    unsigned long currentSym = sym;
    BOOL uminus = NO;
    NSMutableString *ic;
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$PLUS"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
//        returnValue = [NSString stringWithString:@"+"];
    }
    else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$MINUS"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
        uminus = YES;        
//        returnValue = [self newTemp]
//        NSMutableString *ic = [NSString stringWithString:@"uminus,%@,-,%@"];
    }
    else sym = currentSym;
    
    NSString *item1 = [self item];
    returnValue = item1;
    if( item1 != nil ){       
        
//        returnValue = [returnValue stringByAppendingString:item1];
        
        NSString *plusOperators = [self plusOperators];
        
        while ( plusOperators != nil ) {
            NSString *item2 = [self item];
            if ( item2 != nil ) {
                if (uminus) {
                    returnValue = [self newTemp];
                    ic = [NSString stringWithFormat:@"uminus,%@,-,%@",item1,returnValue];
                    [intermediateCode addObject:ic];
                    NSLog(@"Generated an intermeidate code:%@",ic);
                    uminus = NO;
                }
                else returnValue = item1;
                
                NSString *newtemp = [self newTemp];
                ic = [NSString stringWithFormat:@"%@,%@,%@,%@",plusOperators,returnValue,item2,newtemp];
                [intermediateCode addObject:ic];
                NSLog(@"Generated an intermediate code:%@",ic);
                
                returnValue = newtemp;
            
            }
            else return nil;
            plusOperators = [self plusOperators];
        }//while
        
        return returnValue;
    }//if
    else { sym = currentSym; return nil; }
}//表达式

-(NSString *) item
{
    NSString *returnValue;
    NSString *factor1 = [self factor];
    
    if ( factor1 != nil ) {
        
        NSString *multiOperators = [self multiOperators];
        
        while ( multiOperators != nil ) {
            NSString *factor2 = [self factor];
            if ( factor2 != nil ) {

                returnValue = [self newTemp];
                
                NSMutableString *ic = [NSMutableString stringWithFormat:@"%@,%@,%@,%@",multiOperators,factor1,factor2,returnValue];
                [intermediateCode addObject:ic];
                NSLog(@"Generated an intermediate code:%@",ic);
                
                factor1 = returnValue;
                 
            }
            else return nil;
            multiOperators = [self multiOperators];
        }//while
        
        return factor1;
    }//if
    else return nil;
}

-(NSString *) factor
{
    unsigned long currentSym = sym;    
    NSString *returnValue;
    
    if ( [[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$ID"] ) {
        //
        //
        returnValue = [self identifier];
        if (returnValue != nil) {
            return returnValue;
        }
        else return nil;
    }//if ID
    else if ( [[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$INT"] ){
        //
        //
        returnValue = [self unsignedInt];
        if (returnValue != nil) {
            return returnValue;
        }
        else return nil;
    }//if INT
    else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$LPAR"]){
        NSLog(@"Parser Effected");;
        
        ++sym;
        NSString *expression = [self expression];
        
        if ( expression != nil ) {
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$RPAR"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                //
                //
                returnValue = expression;
                return returnValue;
            }//if RPAR
            else { sym = currentSym; return nil; }
        }// if ( expression != nil )
        else { sym = currentSym; return nil; }
        
    }//if LPAR
    else return nil;
}

-(NSString *) plusOperators
{
    unsigned long currentSym = sym;
    NSDictionary *lexerResult = [lexer lexicalAnalyze:&sym];
    NSString *returnValue = [[lexerResult allKeys] lastObject];
    if ([returnValue isEqualToString:@"$PLUS"]) {
        NSLog(@"About to %@",returnValue);
        ++sym;
        
        //
        //
        return returnValue;
    }//if PLUS
    else if ([returnValue isEqualToString:@"$MINUS"]){
        NSLog(@"About to %@",returnValue);
        ++sym;
        //
        //
        return returnValue;
    }//if MINUS
    else { sym = currentSym; return nil; }
}

-(NSString *) multiOperators
{
    unsigned long currentSym = sym;
    NSDictionary *lexerResult = [lexer lexicalAnalyze:&sym];
    NSString *returnValue = [[lexerResult allKeys] lastObject];
    if ( [returnValue isEqualToString:@"$MULTI"] ) {
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return returnValue;
    }//if MULTI
    else if ( [returnValue isEqualToString:@"$DIVIDE"] ){
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return returnValue;
    }//if DIVIDE
    else { sym = currentSym; return nil; }
}

-(NSArray *) conditionStatement
{
//    unsigned long ic1Index,ic2Index;
    unsigned long currentSym = sym;
    
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$IF"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
//        NSNumber *ifIndex = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
        
        NSArray *condition = [self condition];
        if ( condition != nil ) {
            
            NSArray *truelist = [NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:[intermediateCode count]]];
            NSArray *falselist = [NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:([intermediateCode count]+1)]];
            
            NSMutableString *ic = [NSMutableString stringWithFormat:@"j%@,%@,%@,0",
                            [condition objectAtIndex:1],[condition objectAtIndex:0],[condition objectAtIndex:2]];
            [intermediateCode addObject:ic];
            NSLog(@"Generated an intermediate code:%@",ic);
            ic = [NSMutableString stringWithString:@"j,-,-,0"];
            [intermediateCode addObject:ic];
            NSLog(@"Generated an intermediate code:%@",ic);
            
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$THEN"]){
                NSLog(@"Parser Effected");;
                ++sym;
                
                NSNumber *thenIndex = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
                
                NSArray *statement = [self statement];
                if ( statement != nil ) { 
                    
                    [self backpatch:truelist withValue:[thenIndex stringValue]];
                    return [NSArray arrayWithObjects:falselist, statement, nil];
                }
                else { sym = currentSym; return nil; }
            }//if IF
            else { sym = currentSym; return nil; }
        }//if condition
        else { sym = currentSym; return nil; }
    }//if IF
    else { sym = currentSym; return nil; }
}

-(NSArray *) loopStatement
{
    unsigned long currentSym = sym;
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$WHILE"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
        NSNumber *whileIndex = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
        
        NSArray *condition = [self condition];
        if ( condition != nil ) {
            
            NSArray *truelist = [NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:[intermediateCode count]]];
            NSArray *falselist = [NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:([intermediateCode count]+1)]];
            
            NSMutableString *ic = [NSMutableString stringWithFormat:@"j%@,%@,%@,0",
                            [condition objectAtIndex:1],[condition objectAtIndex:0],[condition objectAtIndex:2]];
            [intermediateCode addObject:ic];
            NSLog(@"Generated an intermediate code:%@",ic);
            ic = [NSMutableString stringWithString:@"j,-,-,0"];
            [intermediateCode addObject:ic];
            NSLog(@"Generated an intermediate code:%@",ic);
            
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$DO"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                
                NSNumber *doIndex = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
                
                NSArray *statement = [self statement];
                if ( statement != nil ) {
                    
                    [self backpatch:statement withValue:[whileIndex stringValue]];
                    [self backpatch:truelist withValue:[doIndex stringValue]];
                    ic = [NSMutableString stringWithFormat:@"j,-,-,%lu",[whileIndex unsignedLongValue]];
                    return falselist;
                }
                else { sym = currentSym; return nil; }
            }
            else { sym = currentSym; return nil; }
        }
        else { sym = currentSym; return nil; }
    }
    else { sym = currentSym; return nil; }   
}

-(NSArray *) condition
{
    NSArray *returnValue;
    
    NSString *expression1 = [self expression];
    if ( expression1 != nil ) {
        
        NSString *compareOperations = [self compareOperations];
        if ( compareOperations != nil ) {
            
            NSString *expression2 = [self expression];
            if ( expression2 != nil ) {
                
                returnValue = [NSArray arrayWithObjects:expression1, compareOperations, expression2, nil];
                //
                //
                //
                //
                return returnValue;
            }
            else return nil;
        }
        else return nil;
    }
    else return nil;
}

-(NSString *) compareOperations
{
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$EQUAL"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return @"=";
    }
    else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$UNEQUAL"]){
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return @"<>";
    }
    else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$SMALLER"]){
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return @"<";
    }
    else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$NOTGREATER"]){
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return @"<=";
    }
    else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$GREATER"]){
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return @">";
    }
    else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$NOTSMALLER"]){
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return @">=";
    }
    else return nil;
}


-(void) error
{
    NSLog(@"ERROR!!!!!!");
}

@end
