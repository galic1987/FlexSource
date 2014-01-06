//
//  FSTestingHelperTests.m
//  FSTestingHelperTests
//
//  Created by Ivo Galic on 18/12/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//
#import "HTMLNode.h"
#import "HTMLParser.h"

#import "PropertyUtil.h"
#import "ClassTestExample.h"

#import "XPathQuery.h"
#include <libxml/xmlreader.h>
#import "ParsingObject.h"
#import "ParsingSource.h"
#import "ParsingField.h"
#import "ParsingURL.h"
#import "ParsingFieldArray.h"

#import "NSObject+FSClassHelper.h"
#import "FlexSource.h"
#import "NSIvoObject.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#ifdef DEBUG
#   define DLog(fmt, ...) DLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif


@interface FSTestingHelperTests : XCTestCase <FlexSourceResponderDelegate>


@end

@implementation FSTestingHelperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
   // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}


-(void)testFlexSource{
    
    //UIWebView *ui = [[UIWebView alloc]init];
   // STAssertNotNil(app, @"UIApplication failed to find the AppDelegate");
    
    NSMutableArray * urls = [NSMutableArray array];
   // [urls addObject:@"http://galic-design.com/flexSourceTests/rule1.xml"]; // non existing
   // [urls addObject:@"http://galic-design.com/flexSourceTests/rule3.xml"]; // broken
    [urls addObject:@"http://galic-design.com/flexSourceTests/rule2.xml"]; // right

    
    FlexSource *fx = [[FlexSource alloc]initWithRuleUrls:urls];
    fx.log = NO;
    [fx updateRules];
    
    
    
    NSDate *fiveSecondsFromNow = [NSDate dateWithTimeIntervalSinceNow:65.0];
    
    fx.delegate = self;
    // delegate method include
    [fx parse];
    
    [[NSRunLoop currentRunLoop] runUntilDate:fiveSecondsFromNow];
    
    
}


-(void)finishedObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message{
    NSLog(@"#### %@%@%@%@",resourceID,object,status,message);
    
    // indirect
    // 1. getObject from dictionary with objectId after some flag
    // 2. autoconnect etc...
    
    // direct
    // 1. cast object to expected object and connect to gui
    // 2. autoconnect gui via samenaming mechanism setter
}

-(void)errorOnObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message{
    
    NSLog(@"**** %@%@%@%@",resourceID,object,status,message);
    
}


-(void)failedParsing:(NSString*)description{
    NSLog(@"!!!! Parsing fail %@",description);

}

// test delegates
-(void)testResultOnObject:(NSMutableArray *)objects result:(BOOL)result msg:(NSString*)msg{
    for (ParsingTest *object in objects) {
        
            NSLog(@"//// Test log \n Result:%@ \n Xpath:%@ \n Expected value:%@ \n Current value: %@ \n NodeBuffer: %@",object.result, object.xpath,object.expectedValue,object.currentValue,object.xpathParsingBuffer);
    }

}



@end
