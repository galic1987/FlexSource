//
//  PropertyUtil.h
//  FlexSource
//
//  Created by Ivo Galic on 9/19/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface PropertyUtil : NSObject

+ (NSDictionary *)classPropsFor:(Class)klass;

@end
