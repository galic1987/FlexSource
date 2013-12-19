//
//  ParsingURL.h
//  FlexSource
//
//  Created by Ivo Galic on 9/22/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingURL : NSObject

@property int step;

@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSMutableDictionary * headers;

@property (nonatomic, retain) NSMutableArray * fields;

@property int javascript;
@property int waitJSComputation;

@end
