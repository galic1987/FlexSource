//
//  ParsingField.h
//  FlexSource
//
//  Created by Ivo Galic on 23/11/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParsingFieldArray.h"

@interface ParsingField : NSObject



@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type; //string or array
@property (nonatomic, retain) NSString * xpath;

// this has value only if this is test
@property (nonatomic, retain) NSString * expectedValue;





@end
