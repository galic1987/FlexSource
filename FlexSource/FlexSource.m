//
//  FlexSource.m
//  FlexSource
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "FlexSource.h"

@implementation FlexSource
@synthesize objectPool,resultPool,ruleUrls,currentRule,numberOfThreads,frameworkVersion,log,delegate,strictSchemaValidation;


// 1. init
-(id)initWithRuleUrl:(NSString*)ruleUrl{
   
    if ( self = [super init] ) {

        ruleUrls = [[NSMutableArray  alloc]init];
        objectPool = [[NSMutableArray  alloc]init];
        resultPool = [[NSMutableDictionary  alloc]init];
        

        numberOfThreads = [[SettingsHelper get:@"numberOfThreads"] integerValue];
        strictSchemaValidation = NO;
        frameworkVersion = [[SettingsHelper get:@"frameworkVersion"] integerValue];
        
        //****** load rule from sandbox

        
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
        strictSchemaValidation = NO;
        frameworkVersion = [[SettingsHelper get:@"frameworkVersion"] integerValue];
        
        //****** load rule from sandbox
        
        
        if ([ruleUrlss count]==0) {
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
        if (log) {
            DLog(@"Starting with url rule %@",u.absoluteString);
        }
        NSURLResponse * response = nil;
        //[request setCachePolicy:NSURLCacheStorageNotAllowed];
        
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        
        
        
        if (error == nil)
        {
            //NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
           // DLog(@"%i", [httpResponse statusCode]);
            
          //  NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
          //  DLog(@"%@",newStr);
            
            
            // 1.2 look for parse version
            if (currentRule != nil) {
                if (![ParsingRule checkNewFileVersion:currentRule.v parseRule:data]) {
                    // It is not new just return
                  //  continue;
                }
            }
            
            // if actual just continue to next
            
            
            // ******* VALIDATION
//            NSString* str = [SettingsHelper get:@"schemaURL"];@""
//            NSData* schema = [str dataUsingEncoding:NSUTF8StringEncoding];
            
            NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ruleSchema"
                                                             ofType:@"xsd"];

            NSData *schema = [NSData dataWithContentsOfFile:path];
            BOOL valid = [ParsingRule validateRule:data withSchema:schema];
            
            
            //DLog(@"%@",schema);

            if (!valid) {
                if (strictSchemaValidation) {
                    // put skip condition
                    DLog(@"Schema Validation fail skipping this rule");
                    [self failedParsing:u.absoluteString];
                    continue;
                }
            }
            
            // ******* MAKE TRY
            NSMutableArray *ar = [ParsingRule parseRule:data];
            
            
            if (ar == nil || [ar count] == 0 ) {
                // ***** PARSER FAIL
                [self failedParsing:u.absoluteString];
            }else{
                // Parser OK

                ParsingRule *r = [[ParsingRule alloc]init];
                r.log = self.log;
                r.dateDownloaded = [NSDate date];
                r.url = u;
                r.v = [ParsingRule getVersion:data];
                
                objectPool = ar; //put objects in objectpool
                currentRule = r; // put new rule
                DLog(@"Using rule with url %@",u.absoluteString);

                
                // ***** trigger save rule to sandbox
                
                return;
            }
            
            // ** UNKNOWN FAIL
        }else{
           if(log) DLog(@"%@",[error localizedDescription]);
            // **************** MISSING ERROR HANDLING
            [self failedParsing:u.absoluteString];

        }
        
    }
    
}


// 3. parse data from internet/ refresh
-(void)parse{
    // 1. take current rule and send To ParsingObject
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:numberOfThreads];
    
    //***** ADD Delegate notifier
    for (ParsingObject *o in objectPool) {
        o.delegate = self;
        o.log = self.log;

    }
    
    
    for (ParsingObject *obj in objectPool) {
//        if ([obj.type isEqualToString:@"NSIvoObject2"]) {
//            [obj main];
//        }
       if (log) DLog(@"Adding object to queue %@",obj.name);
        [queue addOperation:obj];
    }

}


# pragma mark Delegate

-(void)finishedObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message{
    
    // so new data will be overwritten
    [resultPool setObject:object forKey:resourceID];
    
    if (log) {
        DLog(@"FX ok %@%@%@%@",resourceID,object,status,message);
    }
    [delegate finishedObjectWithId:resourceID theObject:object withStatus:status withMessage:message];
    
}

-(void)errorOnObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message{
    
    if (log) {
        DLog(@"FX error %@%@%@%@",resourceID,object,status,message);
    }
    [delegate errorOnObjectWithId:resourceID theObject:object withStatus:status withMessage:message];
    
}

-(void)failedParsing:(NSString*)description{
    
    if (log) {
        DLog(@"Parsing fail %@",description);
    }
    
    [delegate failedParsing:description];
}


-(void)testResultOnObject:(NSMutableArray *)objects result:(BOOL)result msg:(NSString*)msg{
    for (ParsingTest *object in objects) {

        if (log) {
        DLog(@"Test log \n Result:%@ \n Xpath:%@ \n Expected value:%@ \n Current value: %@ \n NodeBuffer: %@",object.result, object.xpath,object.expectedValue,object.currentValue,object.xpathParsingBuffer);
        }
    }
    [delegate testResultOnObject:objects result:result msg:msg];
    
}








@end
