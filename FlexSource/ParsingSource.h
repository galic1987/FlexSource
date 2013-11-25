//
//  ParsingSource.h
//  FlexSource
//
//  Created by Ivo Galic on 23/11/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingSource : NSObject
@property  int  priority;
@property (nonatomic, retain) NSMutableArray  * urls;

@end
