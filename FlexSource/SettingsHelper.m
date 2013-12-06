//
//  SettingsHelper.m
//  TuWien Calendar
//
//  Created by Ivo Galic on 11/26/11.
//  Copyright (c) 2011 Galic Design. All rights reserved.
//

#import "SettingsHelper.h"




@implementation SettingsHelper

static NSUserDefaults *prefs;

static NSString * frameworkVersion = @"1";


+ (void)registerDefaultsFromSettingsBundle {
    
    ////////////////
    /// Default URL Rule settings
    [self set:@"http://galic-design.com/flexSourceTests/rule1.xml" forKey:@"baseRuleURL"];

    
    [self set:@"1" forKey:@"numberOfThreads"];

    [self set:frameworkVersion forKey:@"frameworkVersion"];

    
    
    

    
    
}


+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        [NSUserDefaults initialize];
        prefs= [NSUserDefaults standardUserDefaults];
        
        [self registerDefaultsFromSettingsBundle];

    }
}

+ (NSString *)get:(NSString*)settings{
    NSString * sett = [prefs stringForKey:settings];
    if (sett == nil) {
        NSLog(@"Settings for %@ key are null warning", settings);
    }
    return sett;
}

+ (void)set:(NSString*)settings forKey:(NSString*)key{
    [prefs setObject:settings forKey:key];
}



@end

