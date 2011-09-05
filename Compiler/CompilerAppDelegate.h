//
//  CompilerAppDelegate.h
//  Compiler
//
//  Created by Power Qian on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Parser.h"

@interface CompilerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    Parser *aParser;
}

@property (assign) IBOutlet NSWindow *window;

@end
