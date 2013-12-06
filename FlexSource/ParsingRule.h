//
//  ParsingRule.h
//  FlexSource
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPathQuery.h"
#include <libxml/xmlreader.h>
#import "ParsingObject.h"
#import "ParsingSource.h"
#import "ParsingField.h"
#import "ParsingURL.h"
#import "ParsingFieldArray.h"

#import "NSObject+FSClassHelper.h"



@interface ParsingRule : NSObject
@property (nonatomic, retain) NSMutableArray<NSObject> * type;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSDate *dateDownloaded;

@property (nonatomic) double v;


// not used but maybe open for further development

@property (nonatomic, retain) NSString *md5Hash;
@property (nonatomic) BOOL parsingError;
@property (nonatomic,retain) NSString *parsingStatus;
@property (nonatomic,retain) NSData *ruleRaw;




// return objectPool
+(NSMutableArray*)parseRule:(NSData*)content;
+(BOOL)checkNewFileVersion:(double)version parseRule:(NSData*)content;
+(double)getVersion:(NSData*)content;



@end
