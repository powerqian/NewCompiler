//
//  CompilerAppDelegate.m
//  Compiler
//
//  Created by Power Qian on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CompilerAppDelegate.h"
#define kNo @"No"
#define kSuccess @"Success"
#define kFail @"Fail"

@implementation CompilerAppDelegate

@synthesize window;
@synthesize filePath;
@synthesize results;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    aParser = [[Parser alloc] init];
}

- (IBAction)chooseFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];

    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        filePath = [[openPanel URLs] lastObject];
        loadFromFile = [[NSString alloc] initWithContentsOfURL:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
    }
    
    [text setStringValue:loadFromFile];
    [start setEnabled:YES];
    [filePath retain];
}


- (IBAction)start:(id)sender
{
//    NSLog(@"%@",[self.filePath lastPathComponent]);
    
    NSURL *keywordPath = [[self.filePath URLByDeletingLastPathComponent]
                          URLByAppendingPathComponent:@"Keyword.plist"];
    
    [aParser.lexer loadText:loadFromFile withKeyWordPath:keywordPath];
    NSString *parserResult = [aParser start];
    
    if ([parserResult isEqualToString:kFail]) { 
//        || aParser.sym <= [aParser.lexer.preProcessedText length]) {
        NSAlert *dialog = [[NSAlert alloc] init];
        [dialog setAlertStyle:NSCriticalAlertStyle];
        [dialog setMessageText:
         @"语法出错！\r\n请仔细检查代码！"];
        [dialog addButtonWithTitle:@"OK"];
        [dialog runModal];
        [dialog release];
    }
    else {
        self.results = [NSMutableArray arrayWithArray:aParser.intermediateCode];
        for ( int i = [[NSNumber numberWithUnsignedLong:([results count]-1)] intValue] ; i>=0 ; i-- ) {
            [[results objectAtIndex:i] setObject:[NSNumber numberWithUnsignedLong:i] forKey:kNo];
        }
        [resultsTableView reloadData];
        [start setEnabled:NO];
        [clear setEnabled:YES];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [results count];
}
- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex {
    NSMutableDictionary *result = [results objectAtIndex:rowIndex];
    id keyName = [aTableColumn identifier];
    return [result objectForKey:keyName];
}

@end
