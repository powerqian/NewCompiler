//
//  CompilerAppDelegate.m
//  Compiler
//
//  Created by Power Qian on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CompilerAppDelegate.h"

@implementation CompilerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    aParser = [[Parser alloc] init];
    [aParser start];
    
    for (NSString *str in aParser.intermediateCode){
        NSLog(@"%@",str);
    }
    
}

@end
