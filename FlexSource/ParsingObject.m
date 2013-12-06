//
//  ParsingObject.m
//  FlexSource
//
//  Created by Ivo Galic on 9/16/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "ParsingObject.h"

@implementation ParsingObject
@synthesize name,type,priority,loading,sources;





-(void)main{
    NSLog(@"executing %@",name);
    
    // 0.1 Create the object dynamically
    NSObject * dynoObject = [[NSClassFromString(self.type) alloc] init];

    
    // to be done dependencies maybe in future
    for (ParsingSource *src in self.sources) {
        for (ParsingURL *url in src.urls) {
            //NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            //[queue setMaxConcurrentOperationCount:1];
            
            // 1. build request
            // ****************** MISSING OHTER PARAMETERES (timeout, request type etc) TBD
            NSURL *uri = [[NSURL alloc]initWithString:url.uri];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:uri ];
            
            // 2. make urls
            if (url.headers != NULL) {
                NSArray *keyArray =  [url.headers allKeys];
                int count = [keyArray count];
                for (int i=0; i < count; i++) {
                    [request setValue:[url.headers objectForKey:[ keyArray objectAtIndex:i]] forHTTPHeaderField:[keyArray objectAtIndex:i]];
                }
            }
        
            
            
            // 3. start evaluation
            
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&response
                                                              error:&error];
            // 4. finish put it to fields
            if (error == nil)
            {
                // Parse data here
                
                
                // 4.2 Go throught the fiedls und update dynamically
                for (id field in url.fields) {
                    // check if filed or arrayfield
                    if([field isKindOfClass:[ParsingField class]]){
                        ParsingField *parsingField = field;
                        NSArray *xpathDataParsed = PerformHTMLXPathQuery(data, parsingField.xpath);
                        if (xpathDataParsed != NULL) {
                            NSMutableDictionary * xpathContent = [xpathDataParsed objectAtIndex:0];
                            [dynoObject setValueForObject:xpathContent fieldName:parsingField.name classPropsFor:[dynoObject class] obj:dynoObject];
                        }else{
                            // error not matching file
                            NSLog(@"cannot find xpath value for field %@ with value %@",parsingField.name,parsingField.xpath);
                        }
                    }else{
                        
                        // *** LAter
                        // arrayfield
                        // do the recursive call for arrayfield
                    }
                }

                
                // 4.3 Notify delegate url finished
                
            }else{
                // **************** MISSING ERROR HANDLING
            }
            
            
            
        }
        // 5. Notify delegate source finished

    }
    // 6. Notify delegate object finished

    
    
}




+ (NSMutableArray*) createParsingField:(NSArray*)fields{
    /// recursive part start
    NSMutableArray *myFields = [[NSMutableArray alloc]init];
    for (NSDictionary *field in fields) {
        // ---> 2.5 start another loop array for type array field
        //NSArray *field = [field objectForKey:@"fields"];
        //for (NSDictionary *field in fields) {
        //NSLog(@"add field %@",field);
        if ([[field objectForKey:@"nodeName"]isEqualToString:@"field"]) {
            NSLog(@"field content %@",[field objectForKey:@"nodeContent"]);
            ParsingField *pf = [[ParsingField alloc]init];
            [pf setAttributesForObject:[field objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingField class] obj:pf];
            pf.xpath =[field objectForKey:@"nodeContent"];
            [myFields addObject:pf];

        }else if([[field objectForKey:@"nodeName"]isEqualToString:@"arrayfield"]) {
            ParsingFieldArray *pfa = [[ParsingFieldArray alloc]init];
            [pfa setAttributesForObject:[field objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingFieldArray class] obj:pfa];
            
            NSArray *arrayFields = [field objectForKey:@"nodeChildArray"];
            for (NSDictionary *arrayFieldChild in arrayFields) {
                

                if ([[arrayFieldChild objectForKey:@"nodeName"]isEqualToString:@"xpath"]) {
                    NSLog(@"xpath content %@",[arrayFieldChild objectForKey:@"nodeContent"]);
                    pfa.xpath =[arrayFieldChild objectForKey:@"nodeContent"];
                }else if([[arrayFieldChild objectForKey:@"nodeName"]isEqualToString:@"arrayobject"]) {
                    // ------> recursive field call
                    [pfa.fieldArray addObject:[ParsingObject createParsingField:[arrayFieldChild objectForKey:@"nodeChildArray"]]];
                }else{
                    // error
                }
                
            }
            [myFields addObject:pfa];

            
        }else{
            // error
        }
        //}
        
        
    }
    // recursive part end
    return myFields;

}


@end
