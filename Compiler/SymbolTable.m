//
//  SymbolTable.m
//  Compiler
//
//  Created by Power Qian on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SymbolTable.h"

@implementation SymbolTable

//@synthesize aNewTable;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
//        aNewTable = [NSMutableArray arrayWithCapacity:1024];
    }
    return self;
}

-(NSMutableArray *)makeANewTable
{
    return [NSMutableArray arrayWithCapacity:1024];
}

-(unsigned long) addToTable:(NSMutableArray *)aNewTable ReturnIndex:(NSString *)anObject
{
    for ( NSDictionary *aDic in aNewTable ){
        if ([[aDic allKeys] containsObject:anObject]) {
            return [aNewTable indexOfObject:aDic];
        }
    }
    
    [aNewTable addObject:[NSDictionary dictionaryWithObject:@"" forKey:anObject]];
    return [aNewTable indexOfObject:[aNewTable lastObject]];
}

-(void) setDetailinTable:(NSMutableArray *)aNewTable ForObject:(NSString *)anObject value:(NSString *)aValue
{
    for ( NSDictionary *aDic in aNewTable ){
        if([[aDic allKeys] containsObject:anObject]){
            [aDic setValue:aValue forKey:anObject];
        }
        
    }
}


//-(unsigned long) searchForObject:(NSString *)anObject
//{
//    BOOL hasFound = NO;
//
//    return hasFound;
//}

@end
