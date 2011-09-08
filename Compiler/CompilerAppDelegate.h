//
//  CompilerAppDelegate.h
//  Compiler
//
//  Created by Power Qian on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Parser.h"
#import "Lexer.h"

@interface CompilerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    IBOutlet NSTextField *text;
    IBOutlet NSTableView *resultsTableView;
    IBOutlet NSButton *start;
    IBOutlet NSButton *clear;
    
    NSString *loadFromFile;
    NSURL *filePath;
    Parser *aParser;
    NSMutableArray *results;
}

@property (assign) IBOutlet NSWindow *window;

@property (retain) NSURL *filePath;
@property (retain) NSMutableArray *results;


- (IBAction)start:(id)sender;
- (IBAction)chooseFile:(id)sender;


@end
