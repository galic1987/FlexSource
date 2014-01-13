//
//  FlexSourceTests.h
//  FlexSourceTests
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


#import "PropertyUtil.h"

#import "XPathQuery.h"
#include <libxml/xmlreader.h>
#import "ParsingObject.h"
#import "ParsingSource.h"
#import "ParsingField.h"
#import "ParsingURL.h"
#import "ParsingFieldArray.h"

#import "NSObject+FSClassHelper.h"
#import "FlexSource.h"
#import "NSIvoObject.h"
#import <UIKit/UIKit.h>

@interface FlexSourceTests : SenTestCase <FlexSourceResponderDelegate>

@end
