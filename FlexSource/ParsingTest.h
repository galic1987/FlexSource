//
//  ParsingTest.h
//  FlexSource
//
//  Created by Ivo Galic on 03/01/14.
//  Copyright (c) 2014 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ParsingTest : NSObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *expectedValue;
@property (nonatomic, retain) NSString *currentValue;
@property (nonatomic, retain) NSString *xpath;
@property (nonatomic, retain) NSString *xpathParsingBuffer;

@end
