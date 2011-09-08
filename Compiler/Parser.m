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
#define kOp @"Op"
#define kArg1 @"Arg1"
#define kArg2 @"Arg2"
#define kResult @"Result"


#import "Parser.h"

@implementation Parser
{
    int i; //for newTemp(T)
}

@synthesize intermediateCode;
@synthesize lexer;
@synthesize sym;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sym = 0;
        lex = [[NSArray alloc] init];
//        table = [[SymbolTable alloc] init];


        lexer = [[Lexer alloc] init];
        i = 0;
    }
    
    return self;
}

-(void) backpatch:(NSArray *)aList withValue:(NSNumber *)aValue
{
    for ( NSNumber *aNum in aList ) {
        
//        NSLog(@"backpatch intermediate code:%@ with value %@",[intermediateCode objectAtIndex:[aNum unsignedLongValue]],aValue);
        
        
        NSMutableDictionary *numToBackpatch = [intermediateCode objectAtIndex:[aNum unsignedLongValue]];
        [numToBackpatch setObject:aValue forKey:kResult];
//        [stringToBackpatch replaceCharactersInRange:[stringToBackpatch rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] 
//                                                                     options:NSBackwardsSearch] 
//                                         withString:aValue]; 
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
    constTable = [NSMutableArray arrayWithCapacity:1024];
    commonTable = [NSMutableArray arrayWithCapacity:1024];
    intermediateCode = [NSMutableArray arrayWithCapacity:1024];
//    [lexer loadText];
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
    unsigned long whileSym;
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$CONST"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
        NSDictionary *constDefine = [self constDefine];
        if ( constDefine != nil ) {
            
            [constTable addObject:constDefine];
            
//            //产生中间代码
//            NSMutableString *ic = [NSString stringWithFormat:@"%@ = %@",
//                            [[constDefine allKeys] lastObject],[[constDefine allValues] lastObject]];
//            NSMutableDictionary *ic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                , nil
//            [intermediateCode addObject:ic];
//            NSLog(@"Generated an intermediate code:%@",ic);
//            //
            whileSym = sym;
            while ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$COMMAR"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                constDefine = [self constDefine];
                if ( constDefine != nil ) {
                    [constTable addObject:constDefine];
                    
//                    //产生中间代码
//                    NSMutableString *ic = [NSString stringWithFormat:@"%@ = %@",
//                                    [[constDefine allKeys] lastObject],[[constDefine allValues] lastObject]];
//                    [intermediateCode addObject:ic];
//                    NSLog(@"Generated an intermediate code:%@",ic);
//                    //
                }//if
                else { sym = currentSym; return nil; }
                whileSym = sym;
            }//while
            sym = whileSym;
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$SEMICOLON"]) {
                ++sym;
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
    unsigned long currentSym = sym;
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
    else { sym = currentSym; return nil; }
}

-(NSString *) variableDeclaration
{
    unsigned long currentSym = sym;
    unsigned long whileSym;
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$VAR"]) {
        NSLog(@"Parser Effected");;    
        ++sym;
        
        NSString *identifier = [self identifier];
        if ( identifier != nil ) {
//            [commonTable retain];
            [commonTable addObject:[NSDictionary dictionaryWithObject:@""
                                                               forKey:identifier]];//添加到符号表
            
            whileSym = sym;
            while ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$COMMAR"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                
                identifier = [self identifier];
                if ( identifier != nil ) {
                    [commonTable addObject:[NSDictionary dictionaryWithObject:@"" forKey:identifier]];//添加到符号表
                }
                else return nil;
                whileSym = sym;                
            }
            sym = whileSym;
            
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
    unsigned long whileSym;
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$BEGIN"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
        NSArray *statement1 = [self statement];
        nextlist = statement1;
        
        if ( statement1 != nil ){
//            unsigned long tempSym;
            whileSym = sym;
            while ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$SEMICOLON"]){
                NSLog(@"Parser Effected");
                ++sym;
                
                NSNumber *Mquad = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
                
                unsigned long tempSym = sym;
                NSArray *statement2 = [self statement];
                if( statement2 != nil ){
                    
                    [self backpatch:statement1 withValue:Mquad];
                    nextlist = statement2;
                    statement1 = statement2;
                }
//                else if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$END"]) {
//                    NSLog(@"Parser Effected");
//                    ++sym;
//                    
//                    return nextlist;
//                }
                else { sym = tempSym; whileSym = sym; break; }
                whileSym = sym;
            }
            sym = whileSym;
        }
        else { sym = currentSym; return nil; }
        
        if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$END"]) {
            NSLog(@"Parser Effected");
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
      
//        NSMutableString *ic = [NSString stringWithFormat:@":=,%@,-,%@",
//                        [[assignmentStatement allValues] lastObject],[[assignmentStatement allKeys] lastObject]];
        
        NSMutableDictionary *ic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @":=", kOp,
                            [[assignmentStatement allValues] lastObject], kArg1,
                            @"--", kArg2,
                            [[assignmentStatement allKeys] lastObject], kResult,
                            nil];
        [intermediateCode addObject:ic];
//        NSLog(@"%@",ic);        
        //
        //
        return nextlist;
    }//赋值语句
    else {
        NSArray *conditionStatement = [self conditionStatement];
        if ( conditionStatement != nil ) {
            nextlist = conditionStatement;
//            [nextlist arrayByAddingObjectsFromArray:conditionStatement];
            return nextlist;
        }//条件语句
        else {
            NSArray *loopStatement = [self loopStatement];
            if ( loopStatement != nil ) {
                //
                //
//                [nextlist arrayByAddingObjectsFromArray:loopStatement];
                nextlist = [loopStatement objectAtIndex:0];
//                NSString *ic = [NSString stringWithFormat:@"j,-,-,%@",[loopStatement objectAtIndex:1]];
                NSMutableDictionary *ic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"j", kOp,
                                    @"--", kArg1,
                                    @"--", kArg2,
                                    [loopStatement objectAtIndex:1], kResult,
                                    nil];
                [intermediateCode addObject:ic];
//                NSLog(@"%@",ic);
                return nextlist;
            }//循环
            else {
                NSArray *complexStatement = [self complexStatement];
                if ( complexStatement != nil ) {
                    nextlist = complexStatement;
                    return nextlist;
                }//复合
                else { sym = currentSym; return nil; }
//                else {
//                    unsigned long newCurrentSym = sym;
//                    if ( [[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$END"] ) {
//                        sym = newCurrentSym;
//                        return nil;
//                    }
//                    else { sym = currentSym; return nil; }
//                }//空语句
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
    NSMutableDictionary *ic;
    
    if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$PLUS"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
//        returnValue = [NSString stringWithString:@"+"];
    }
    else
    {
        sym = currentSym;
        if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$MINUS"]) {
        NSLog(@"Parser Effected");;
        ++sym;
        
        uminus = YES;
        }
        else sym = currentSym;
    }
    
    
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
//                    ic = [NSString stringWithFormat:@"uminus,%@,-,%@",item1,returnValue];
                    ic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"-", kOp,
                          item1, kArg1,
                          @"--", kArg2,
                          returnValue, kResult,
                          nil];
                    [intermediateCode addObject:ic];
//                    NSLog(@"Generated an intermeidate code:%@",ic);
                    uminus = NO;
                }
                
                NSString *newtemp = [self newTemp];
//                ic = [NSString stringWithFormat:@"%@,%@,%@,%@",plusOperators,returnValue,item2,newtemp];
                ic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      plusOperators, kOp,
                      returnValue, kArg1,
                      item2, kArg2,
                      newtemp, kResult,
                      nil];
                [intermediateCode addObject:ic];
//                NSLog(@"Generated an intermediate code:%@",ic);
                
                returnValue = newtemp;
            }
//            else return nil;
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
                
//                NSMutableString *ic = [NSMutableString stringWithFormat:@"%@,%@,%@,%@",multiOperators,factor1,factor2,returnValue];
                NSMutableDictionary *ic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    multiOperators, kOp,
                                    factor1, kArg1,
                                    factor2, kArg2,
                                    returnValue, kResult,
                                    nil];
                [intermediateCode addObject:ic];
//                NSLog(@"Generated an intermediate code:%@",ic);
                
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
    
    NSString *identifier = [self identifier];
    if ( identifier != nil ) {
        return identifier;
    }//if ID
    else 
    {
        sym = currentSym;
        NSDictionary *lexerResult = [lexer lexicalAnalyze:&sym];
        if ( [[[lexerResult allKeys] lastObject] isEqualToString:@"$INT"] ){
            ++sym;
            return [[lexerResult allValues] lastObject];
        
        }// if INT
        else 
        {
            sym = currentSym;
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$LPAR"]){
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
            else { sym = currentSym; return nil; }
        }
    }
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
        return [NSString stringWithString:@"+"];
    }//if PLUS
    else if ([returnValue isEqualToString:@"$MINUS"]){
        NSLog(@"About to %@",returnValue);
        ++sym;
        //
        //
        return [NSString stringWithString:@"-"];
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
        return [NSString stringWithString:@"*"];
    }//if MULTI
    else if ( [returnValue isEqualToString:@"$DIVIDE"] ){
        NSLog(@"Parser Effected");;
        ++sym;
        //
        //
        return [NSString stringWithString:@"/"];
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
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$THEN"]){
                NSLog(@"Parser Effected");;
                ++sym;
                
                NSNumber *Mquad = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
                
                NSArray *statement = [self statement];
                if ( statement != nil ) { 
                    
                    [self backpatch:[condition objectAtIndex:0]  withValue:Mquad];
                    NSArray *returnValue = [NSArray arrayWithArray:[condition objectAtIndex:1]];
                    return [returnValue arrayByAddingObjectsFromArray:statement];
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
        
        NSNumber *M1quad = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
        
        NSArray *condition = [self condition];
        if ( condition != nil ) {
            
            if ([[[[lexer lexicalAnalyze:&sym] allKeys] lastObject] isEqualToString:@"$DO"]) {
                NSLog(@"Parser Effected");;
                ++sym;
                
                NSNumber *M2quad = [NSNumber numberWithUnsignedLong:[intermediateCode count]];
                
                NSArray *statement = [self statement];
                if ( statement != nil ) {
                    
                    [self backpatch:statement withValue:M1quad];
                    [self backpatch:[condition objectAtIndex:0]  withValue:M2quad];
//                    ic = [NSMutableString stringWithFormat:@"j,-,-,%lu",[whileIndex unsignedLongValue]];
                    return [NSArray arrayWithObjects:[condition objectAtIndex:1], M1quad, nil];
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
                
                NSArray *truelist = [NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:[intermediateCode count]]];
                NSArray *falselist = [NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:([intermediateCode count]+1)]];
                
//                NSMutableString *ic = [NSMutableString stringWithFormat:@"j%@,%@,%@,0",compareOperations,expression1,expression2];
                
                NSMutableDictionary *ic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"j%@",compareOperations], kOp,
                                    expression1, kArg1,
                                    expression2, kArg2,
                                    [NSNumber numberWithUnsignedLong:0], kResult,
                                    nil];
                
                [intermediateCode addObject:ic];
//                NSLog(@"Generated an intermediate code:%@",ic);
                
//                ic = [NSMutableString stringWithString:@"j,-,-,0"];
                ic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"j", kOp,
                      @"--", kArg1,
                      @"--", kArg2,
                      [NSNumber numberWithUnsignedLong:0], kResult,
                      nil];
                [intermediateCode addObject:ic];
//                NSLog(@"Generated an intermediate code:%@",ic);
                
                returnValue = [NSArray arrayWithObjects:truelist, falselist, nil];
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
    unsigned long currentSym = sym;
    NSString *lexerResult = [[[lexer lexicalAnalyze:&sym] allKeys] lastObject];
    if ([lexerResult isEqualToString:@"$EQUAL"]) {
        NSLog(@"Parser Effected");
        ++sym;
        //
        //
        return @"=";
    }
    else if ([lexerResult isEqualToString:@"$UNEQUAL"]){
        NSLog(@"Parser Effected");
        ++sym;
        //
        //
        return @"<>";
    }
    else if ([lexerResult isEqualToString:@"$SMALLER"]){
        NSLog(@"Parser Effected");
        ++sym;
        //
        //
        return @"<";
    }
    else if ([lexerResult isEqualToString:@"$NOTGREATER"]){
        NSLog(@"Parser Effected");
        ++sym;
        //
        //
        return @"<=";
    }
    else if ([lexerResult isEqualToString:@"$GREATER"]){
        NSLog(@"Parser Effected");
        ++sym;
        //
        //
        return @">";
    }
    else if ([lexerResult isEqualToString:@"$NOTSMALLER"]){
        NSLog(@"Parser Effected");
        ++sym;
        //
        //
        return @">=";
    }
    else { sym = currentSym; return nil; }
}


-(void) error
{
    NSLog(@"ERROR!!!!!!");
}

@end
