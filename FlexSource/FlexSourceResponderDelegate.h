//
//  FlexSourceResponderDelegate.h
//  FlexSource
//
//  Created by Ivo Galic on 13/12/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlexSourceResponderDelegate <NSObject>

-(void)finishedObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;

-(void)errorOnObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;

@end
