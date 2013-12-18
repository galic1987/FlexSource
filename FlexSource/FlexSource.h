//
//  FlexSource.h
//  FlexSource
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParsingRule.h"
#import "ParsingObject.h"
#import "SettingsHelper.h"
#import "FlexSourceResponderDelegate.h"

@interface FlexSource : NSObject <FlexSourceResponderDelegate>

// finished objects parsed from internet
@property (nonatomic,retain) NSMutableDictionary *resultPool;

// todo pool for parser sorted
@property (nonatomic,retain) NSMutableArray *objectPool;

// NSURL list of urls f some urls fail, try another one
@property (nonatomic,retain) NSMutableArray *ruleUrls;


@property (nonatomic,retain) ParsingRule *currentRule;


// 1. init put nil to use default
-(id)initWithRuleUrl:(NSString*)ruleUrl;
-(id)initWithRuleUrls:(NSMutableArray*)ruleUrls;


// in case of error,
// 2. try to download/update new rules sources -> put in objectPool
-(void)updateRules;


// 3. parse data from internet/ refresh
-(void)parse;



// settings

// background threads for data parsing - default is 3
@property int numberOfThreads;
@property int frameworkVersion;
@property bool log;



// delegate
@property (assign) id delegate;

-(void)finishedObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;

-(void)errorOnObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;



@end
