//
//  ParsingObject.h
//  FlexSource
//
//  Created by Ivo Galic on 9/16/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyUtil.h"
#import "ParsingSource.h"
#import "ParsingURL.h"
#import "ParsingField.h"
#import "ParsingFieldArray.h"
#import "ParsingTest.h"

#import "NSObject+FSClassHelper.h"
#include <objc/objc-runtime.h>
#include <libxml/xmlreader.h>
#import "XPathQuery.h"
#import "FlexSourceResponderDelegate.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#import <UIKit/UIKit.h>




@interface ParsingObject : NSOperation <UIWebViewDelegate,NSURLConnectionDataDelegate>


@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * name;
@property int priority;
@property (nonatomic, retain) NSString * loading;
@property (nonatomic, retain) NSMutableArray  * sources;

// status of parsing object
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * message;

// settings
@property BOOL log;


// delegate // finished or error
@property (assign) id <FlexSourceResponderDelegate> delegate;


// js support
@property (strong) UIWebView *webview;



// data

// loadview locking
@property NSLock * syncLock;



@end
