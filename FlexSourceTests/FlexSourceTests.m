//
//  FlexSourceTests.m
//  FlexSourceTests
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "FlexSourceTests.h"

@implementation FlexSourceTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testBasic
{
    
    NSString *path = [[NSBundle bundleForClass:[self class] ] pathForResource:@"example_rule" ofType:@"xml"];
    NSData *xmlData = [NSData dataWithContentsOfFile:path];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];

    NSArray *objects = [doc nodesForXPath:@"objects/object" error:nil];

    for (GDataXMLElement *object in objects) {
        NSArray *sources = [object nodesForXPath:@"source" error:nil];
        for (GDataXMLElement *source in sources) {
            NSArray *urls = [source nodesForXPath:@"url" error:nil];
            for (GDataXMLElement *url in urls) {
                // call every source
                // get url for 
                GDataXMLNode *uri = [url attributeForName:@"uri"];
                NSLog(@"++++++ %@",uri.stringValue );
                   
                
                NSLog(@"%@",url );
            }
        }
    }

}


- (void)testFullParsing
{
    
    return;
    NSString* file = [[NSBundle bundleForClass:[self class] ] pathForResource:@"example_rule" ofType:@"xml"];
    
    // full unit [NSBundle mainBundle] 
    //NSString *file=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"example_rule.xml"];
    NSError *error = nil;
    
    NSString* content = [NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    NSLog(@"File: %@", file);
    NSLog(@"Content: %@", content);

    HTMLParser *parser = [[HTMLParser alloc] initWithString:content error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        //STFail(@"Cannot open the file");
    }
    
    HTMLNode *bodyNode = [parser body];
    
    // get objects 
    NSArray *inputNodes = [bodyNode findChildTags:@"object"];
    
    
    
    for (HTMLNode *inputNode in inputNodes) {
        
        NSArray *sourcesArray =  [inputNode findChildTags:@"source"];
        
        for (HTMLNode *urls in sourcesArray) {
            NSLog(@"%@",[urls contents] );

            NSArray *urlArray =  [urls findChildTags:@"url"];
            
            for (HTMLNode *urlInner in urlArray) {
                HTMLNode *fields = [urlInner findChildTags:@"field"];

                NSArray *fieldsArray =  [urlInner findChildTags:@"fields"];

                
            } 
        }

        
//        if ([[inputNode getAttributeNamed:@"name"] isEqualToString:@"input2"]) {
//            NSLog(@"%@", [inputNode getAttributeNamed:@"value"]); //Answer to first question
//        }
    }
    
//    NSArray *spanNodes = [bodyNode findChildTags:@"span"];
//    
//    for (HTMLNode *spanNode in spanNodes) {
//        if ([[spanNode getAttributeNamed:@"class"] isEqualToString:@"spantext"]) {
//            NSLog(@"%@", [spanNode allContents]); //Answer to second question
//        }
//    }

    // get rules file from rules database
    // create objectpool with rules file
    // start receiving objects synchro
    // parse objects with xpath
    //
    
    
}

@end
