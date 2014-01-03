//
//  FlexSourceResponderDelegate.h
//  FlexSource
//
//  Created by Ivo Galic on 13/12/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlexSourceResponderDelegate <NSObject>


// finished delegates
-(void)finishedObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;

// error delegates
-(void)errorOnObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;
-(void)failedParsing:(NSString*)description;

// test delegates
-(void)testResultOnObject:(NSMutableArray *)objects result:(BOOL)result msg:(NSString*)msg;

@end
