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
#import "NSObject+FSClassHelper.h"
#include <objc/objc-runtime.h>

@interface ParsingObject : NSOperation


@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * name;
@property int priority;
@property (nonatomic, retain) NSString * loading;
@property (nonatomic, retain) NSMutableArray  * sources;

+ (NSMutableArray*) createParsingField:(NSArray*)fields;

@end
