//
//  ParsingFieldArray.h
//  FlexSource
//
//  Created by Ivo Galic on 23/11/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingFieldArray : NSObject

@property (nonatomic, retain) NSMutableArray * fieldArray; // parsing fields
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * loading;
@property (nonatomic, retain) NSString * xpath;



@end
