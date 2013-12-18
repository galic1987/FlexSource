//
//  NSObject+FSClassHelper.h
//  FlexSource
//
//  Created by Ivo Galic on 24/11/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyUtil.h"
@interface NSObject (FSClassHelper)


- (void)setAttributesForObject:(NSArray *)ar classPropsFor:(Class)klass obj:(id)object;
- (void)setValueForObject:(NSDictionary *)value fieldName:(NSString*)fieldName classPropsFor:(Class)klass obj:(id)object;

- (void)setValueForObjectDirect:(NSString *)value fieldName:(NSString*)fieldName classPropsFor:(Class)klass obj:(id)object;


@end
