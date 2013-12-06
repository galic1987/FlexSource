//
//  FlexSource.m
//  FlexSource
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "FlexSource.h"

@implementation FlexSource
@synthesize objectPool,resultPool,ruleUrls,currentRule,numberOfThreads,frameworkVersion;


// 1. init
-(id)initWithRuleUrl:(NSString*)ruleUrl{
   
    if ( self = [super init] ) {

        ruleUrls = [[NSMutableArray  alloc]init];
        objectPool = [[NSMutableArray  alloc]init];
        resultPool = [[NSMutableDictionary  alloc]init];
        
        
        numberOfThreads = [[SettingsHelper get:@"numberOfThreads"] integerValue];
        
        frameworkVersion = [[SettingsHelper get:@"frameworkVersion"] integerValue];
        
        if (ruleUrl == nil) {
            ruleUrl = [SettingsHelper get:@"baseRuleURL"];
        }
        
        NSURL * url = [[NSURL alloc]initWithString:ruleUrl];
        
        [ruleUrls addObject:url];
    }
    return self;
}

-(id)initWithRuleUrls:(NSMutableArray*)ruleUrlss{
    if ( self = [super init] ) {
        
        ruleUrls = [[NSMutableArray  alloc]init];
        objectPool = [[NSMutableArray  alloc]init];
        resultPool = [[NSMutableDictionary  alloc]init];
        
        
        numberOfThreads = [[SettingsHelper get:@"numberOfThreads"] integerValue];
        
        frameworkVersion = [[SettingsHelper get:@"frameworkVersion"] integerValue];
        
        
        if ([ruleUrls count]==0) {
            [ruleUrls addObject:[SettingsHelper get:@"baseRuleURL"]];
        }
        
        for(NSString *u in ruleUrlss){
            NSURL * url = [[NSURL alloc]initWithString:u];
        [ruleUrls addObject:url];
        }
    }
    return self;
}




// in case of error,
// 2. try to download/update new rules sources -> put in objectPool
-(void)updateRules{
    // 1. for each try -> if good return
    
    for (NSURL *u in ruleUrls) {
        // 1.1 download file --> blocking need to fix
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:u ];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        
        
        
        if (error == nil)
        {
            
            
            // 1.2 look for parse version
            if (currentRule != nil) {
                if (![ParsingRule checkNewFileVersion:currentRule.v parseRule:data]) {
                    // It is not new just return
                    continue;
                }
            }
            
            // if actual just continue to next
            
            
            // ******* MAKE TRY
            NSMutableArray *ar = [ParsingRule parseRule:data];
            if (ar == nil || [ar count] == 0 ) {
                // ***** PARSER FAIL
            }else{
                // Parser OK

                ParsingRule *r = [[ParsingRule alloc]init];
                r.dateDownloaded = [NSDate date];
                r.url = u;
                r.v = [ParsingRule getVersion:data];
                
                objectPool = ar;
                currentRule = r;
                
                return;
            }
            
            // ** UNKNOWN FAIL
        }else{
           if(log) NSLog(@"%@",error);
            // **************** MISSING ERROR HANDLING
        }
        
        
        
        
    }
    
    
}


// 3. parse data from internet/ refresh
-(void)parse{
    // 1. take current rule and send To ParsingObject
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:numberOfThreads];
    
    //***** ADD Delegate notifier
    
    for (ParsingObject *obj in objectPool) {
        if ([obj.name isEqualToString:@"NSIvoObject"]) {
            [obj main];
        }
        NSLog(@"%@",obj.name);
        //[queue addOperation:obj];
    }

}




@end
