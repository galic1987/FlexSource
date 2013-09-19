//
//  JobObjectPool.h
//  FlexSource
//
//  Created by Ivo Galic on 9/19/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParsingObject.h" 

@interface JobObjectPool : NSObject
@property (nonatomic, retain) NSMutableArray * pool;


- (BOOL)addParsingJobToPool:(ParsingObject*)objectJob;

@end
