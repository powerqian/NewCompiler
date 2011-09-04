//
//  Lexer.m
//  Compiler
//
//  Created by Power Qian on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Lexer.h"

@implementation Lexer

@synthesize originText;
@synthesize preProcessedText;
@synthesize result;
//@synthesize table1;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        result = [NSMutableArray arrayWithCapacity:1024];
//        table1 = [[SymbolTable alloc] init];
    }    
    return self;
}

-(void) loadText
{
    NSString *directory = [@"~" stringByExpandingTildeInPath];
    originText = [NSString stringWithContentsOfFile:[directory stringByAppendingString:@"/Compiler/test"] encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"%@",originText);

    keyword = [[NSDictionary dictionaryWithContentsOfFile:@"/Users/powerqian/Developer/Compiler/Compiler/Keyword.plist"] allKeys];
//    for ( NSString *str in keyword ){
//        NSLog(@"%@",str);
//    }
}



- (void) preProcessor
{
//    NSCharacterSet *aSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//    NSRange aRange = [preprocessedText rangeOfCharacterFromSet:aSet];
//    [preprocessedText deleteCharactersInRange:aRange];
    preProcessedText = [NSMutableString stringWithString:originText];
    [preProcessedText replaceOccurrencesOfString:@"\t" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [preProcessedText length])];
    
    while ([preProcessedText rangeOfCharacterFromSet:
            [NSCharacterSet newlineCharacterSet]].location != NSNotFound) {    
    [preProcessedText deleteCharactersInRange:
     [preProcessedText rangeOfCharacterFromSet:
      [NSCharacterSet newlineCharacterSet]]];
    }
    
    NSLog(@"%@",preProcessedText);
//    [preProcessedText retain];
}





- (NSDictionary *) lexicalAnalyze:(unsigned long *)startFrom/* :(unsigned long)to*/
{
    unsigned long i = *startFrom;
    if ( i>=[preProcessedText length] ){
        return [NSDictionary dictionary];
    }
    unsigned long code;
//    unsigned long value;
//    NSString *value;
    NSMutableString *strToken = [NSMutableString stringWithCapacity:1024];
    unichar ch;
//    while (i < to) {
//        [strToken setString:@""];
        
    ch = [preProcessedText characterAtIndex:i];
    while ( ch == ' ' )
    {
        ++i;
        ch = [preProcessedText characterAtIndex:i];
    }
    
    if ( [[NSCharacterSet letterCharacterSet] characterIsMember:ch] )
    {
        
        while ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:ch]) {
            [strToken appendFormat:@"%C",ch];
            ++i;                
            if ( i <[preProcessedText length] ) {
                ch = [preProcessedText characterAtIndex:i];
            }
            else ch = ' ';
        }
        --i;
        ch = ' ';
        
        if ( [keyword containsObject:[NSString stringWithFormat:@"$%@",strToken]] ) {
            NSString *temp = [NSString stringWithFormat:@"$%@",strToken];
            code = [keyword indexOfObject:temp];
        }
        else code = -1;
        if (code == -1) {
            
//            value = [table1 addToTableReturnIndex:strToken];
            [result addObject:[NSDictionary dictionaryWithObject:strToken forKey:@"$ID"]];
            NSLog(@"$ID,%@",strToken);
            *startFrom = i;
            return [NSDictionary dictionaryWithObject:strToken forKey:@"$ID"];
        }
        else {
            [result addObject:[NSDictionary dictionaryWithObject:@"-"
                                                          forKey:[keyword objectAtIndex:code]]];
            NSLog(@"%@,-",[keyword objectAtIndex:code]);
            *startFrom = i;
            return [NSDictionary dictionaryWithObject:@"-" forKey:[keyword objectAtIndex:code]];
        }
    }
    else if ( [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch] )
    {
        while ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch]) {
            [strToken appendFormat:@"%c",ch];
            ch = [preProcessedText characterAtIndex:++i]; 
        }
        --i;
        ch = ' ';
//            value = [table1 addToTable:strToken];
        [result addObject:[NSDictionary dictionaryWithObject:strToken forKey:@"$INT"]];
        NSLog(@"$INT,%@",strToken);
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:strToken forKey:@"$INT"];
    }
    else if ( ch == '=' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$EQUAL"]];
        NSLog(@"$EQUAL,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$EQUAL"];
    }
    else if ( ch == '+' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$PLUS"]];
        NSLog(@"$PLUS,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$PLUS"];
    }
    else if ( ch == '-' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$MINUS"]];
        NSLog(@"$MINUS,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$MINUS"];
    }
    else if ( ch == '*' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$MULTI"]];
        NSLog(@"$MULTI,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$MULTI"];
    }
    else if ( ch == '/' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$DIVIDE"]];
        NSLog(@"$DIVIDE,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$DIVIDE"];
    }
    else if ( ch == ':' && [preProcessedText characterAtIndex:(i+1)] == '=') {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$ASSIGN"]];
        NSLog(@"$ASSIGN,-");
        *startFrom = i+1 ;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$ASSIGN"];
    }
    else if ( ch == '<' ) {
        ++i;
        ch = [preProcessedText characterAtIndex:i];
        if (ch == '>') {
            [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$UNEQUAL"]];
            NSLog(@"$UNEQUAL,-");
            *startFrom = i;
            return [NSDictionary dictionaryWithObject:@"-" forKey:@"$UNEQUAL"];
        }
        if (ch == '=') {
            [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$NOTGREATER"]];
            NSLog(@"$NOTGREATER,-");
            *startFrom = i;
            return [NSDictionary dictionaryWithObject:@"-" forKey:@"$NOTGREATER"];
        }
        --i;
        ch = ' ';
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$SMALLER"]];
        NSLog(@"$SMALLER,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$SMALLER"];
    }
    else if ( ch == '>' ) {
        ++i;
        ch = [preProcessedText characterAtIndex:i];
        if (ch == '=') {
            [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$NOTSMALLER"]];
            NSLog(@"$NOTSMALLER,-");
            *startFrom = i;
            return [NSDictionary dictionaryWithObject:@"-" forKey:@"$NOTSMALLER"];
        }
        --i;
        ch = ' ';
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$GREATER"]];
        NSLog(@"$GREATER,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$GREATER"];
    }
    else if ( ch == '(' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$LPAR"]];
        NSLog(@"$LPAR,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$LPAR"];
    }
    else if ( ch == ')' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$RPAR"]];
        NSLog(@"$RPAR,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$RPAR"];
    }
    else if ( ch == ';' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$SEMICOLON"]];
        NSLog(@"$SEMICOLON,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$SEMICOLON"];
    }
    else if ( ch == ',' ) {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"$COMMAR"]];
        NSLog(@"$COMMAR,-");
        *startFrom = i;
        return [NSDictionary dictionaryWithObject:@"-" forKey:@"$COMMAR"];
    }
    else {
        [result addObject:[NSDictionary dictionaryWithObject:@"-" forKey:@"ERROR!"]];
        NSLog(@"ERROR!");
        *startFrom = i;
        return nil; 
    }
}

@end
