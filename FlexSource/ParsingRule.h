//
//  ParsingRule.h
//  FlexSource
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingRule : NSObject
@property (nonatomic, retain) NSMutableArray<NSObject> * type;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate *dateDownloaded;

// not used but maybe open for further development

@property (nonatomic, retain) NSString *md5Hash;
@property (nonatomic) BOOL parsingError;
@property (nonatomic,retain) NSString *parsingStatus;
@property (nonatomic,retain) NSData *ruleRaw;






@end
