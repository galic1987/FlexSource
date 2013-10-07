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


- (void)testXMLStructureParser
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
                STAssertEqualObjects(uri.stringValue, @"https://addons.mozilla.org/en-us/firefox/addon/firepath/", @"Uri test");
                
                // get step number
                GDataXMLNode *step = [url attributeForName:@"step"];
                NSLog(@"++++++ %@",step.stringValue );
                STAssertEqualObjects(step.stringValue, @"1", @"Step number test");
                
                // get headers
                GDataXMLNode *headersRoot = [[url nodesForXPath:@"headers" error:nil] objectAtIndex:0];
                NSArray *headers = [headersRoot nodesForXPath:@"header" error:nil];
                for (GDataXMLElement *header in headers) {
                    NSString *key = [header attributeForName:@"key"].stringValue;
                    NSString *value = header.stringValue;
                    STAssertEqualObjects(key, @"User-Agent", @"Header Key test");
                    STAssertEqualObjects(value, @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:24.0) Gecko/20100101 Firefox/24.0", @"Header Key test");
                }
                
                // get fields
                GDataXMLNode *fieldsRoot = [[url nodesForXPath:@"fields" error:nil] objectAtIndex:0];
                NSArray *fields = [fieldsRoot nodesForXPath:@"field" error:nil];
                for (GDataXMLElement *field in fields) {
                  //  NSString *name = [field attributeForName:@"name"].stringValue;
                  //  NSString *type = [field attributeForName:@"type"].stringValue;
                    NSString *xpath = field.stringValue;
                    
                    NSLog(@"%@",xpath);
//                    STAssertEqualObjects(key, @"User-Agent", @"Header Key test");
//                    STAssertEqualObjects(value, @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:24.0) Gecko/20100101 Firefox/24.0", @"Header Key test");
                    
                    
                }

                
                return;
                
                NSLog(@"%@",url );
            }
        }
    }

}


- (void)testHTMLParsing
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



-(void)testClassDynamicProperties{
   NSDictionary *d= [PropertyUtil classPropsFor:[ClassTestExample class]];
    
    
    ClassTestExample *c = [[ClassTestExample alloc]init];
    c.test = @"dsad";
    
    
    for (NSString * key in d) {
        if (true) { //matching key
            [c setValue:d[key] forKey:key ];
        }
    }
    NSLog(@"%@",c.test);
    
    STAssertEqualObjects(c.test, @"NSString", @"Must be NSString");

    
}


-(void)testXPath{
    
    NSString *urlAsString = @"https://addons.mozilla.org/en-us/firefox/addon/firepath/";
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];
    /* Return Value
     The downloaded data for the URL request. Returns nil if a connection could not be created or if the download fails.
     */
    if (response == nil) {
        // Check for problems
        if (requestError != nil) {

        }
    }
    else {
        NSArray *tdNodes = PerformHTMLXPathQuery(response, @"//*[@id='addon'][1]");
        NSLog(@"+++ %@",tdNodes);
       // NSLog(@"%@",[[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding] );


    }
    
    
    
   }





@end
