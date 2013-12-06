//
//  ParsingRule.m
//  FlexSource
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "ParsingRule.h"

@implementation ParsingRule

@synthesize url,dateDownloaded,md5Hash,parsingError,parsingStatus,type,ruleRaw,v;



+(double)getVersion:(NSData*)content{
    NSString *fileVersion = [[PerformHTMLXPathQuery(content, @"//objects/@fileversion") objectAtIndex:0] objectForKey:@"nodeContent"];
    
    return [fileVersion doubleValue];

}


+(BOOL)checkNewFileVersion:(double)version parseRule:(NSData*)content{
    double checkVersion = [ParsingRule getVersion:content];
    if (checkVersion >  version) {
        return YES;
    }else{
        return NO;
    }
    
    
}




+(NSMutableArray*)parseRule:(NSData*)content{
    
    NSLog(@"Content: %@", content);
    
    
    // Summary
    // parsing style singlethreaded sequential blocking non failure verificaiton done in xsl
    
    // in rule object (XML)
    // in doc object (HTML)
    // out NSArray of objects
    
    // 1. parser version == file version otherwise error
    NSString *parserVersion = [[PerformHTMLXPathQuery(content, @"//objects/@parserversion") objectAtIndex:0] objectForKey:@"nodeContent"];
    NSString *fileVersion = [[PerformHTMLXPathQuery(content, @"//objects/@fileversion") objectAtIndex:0] objectForKey:@"nodeContent"];
    
    // need to check current system capabilities TODO Central Singleton settings file
    if (![parserVersion isEqualToString:fileVersion]) {
        // return system does not have this parser version
    }
    
    NSMutableArray *pool = [[NSMutableArray alloc]init];
    
    // 2. each object in loop xpath query -- sort by priority
    NSArray *objects = PerformXMLXPathQuery(content, @"//objects/object");
    for (NSDictionary *object in objects) {
        // ---> 2.1 start another loop sources for each object -- sort by priority
        ParsingObject * parsingObject = [[ParsingObject alloc]init];
        parsingObject.sources = [NSMutableArray array];
        
        //[parsingObject setAttributesForObject:[object objectForKey:@"nodeAttributeArray"]];
        [parsingObject setAttributesForObject:[object objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingObject class] obj:parsingObject];
        
        //NSLog(@"OOO %@",parsingObject.name);
        
        NSArray *sources = [object objectForKey:@"nodeChildArray"];
        for (NSDictionary *source in sources) {
            ParsingSource *parsingSource = [[ParsingSource alloc]init];
            parsingSource.urls = [NSMutableArray array];
            [parsingSource setAttributesForObject:[source objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingSource class] obj:parsingSource];
            
            //NSLog(@"111 %@",source);
            // ---> 2.2 start another loop urls for each soruce -- sort by steps
            NSArray *urls = [source objectForKey:@"nodeChildArray"];
            
            for (NSDictionary *url in urls) {
                ParsingURL * parsingUrl = [[ParsingURL alloc]init];
                [parsingUrl setAttributesForObject:[url objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingURL class] obj:parsingUrl];
                
                
                
                //NSLog(@"222 %@",url);
                NSArray *urlChilds = [url objectForKey:@"nodeChildArray"];
                // ---> 2.3 start another loop fields for each object
                for (NSDictionary *urlChild in urlChilds) {
                    if ([[urlChild objectForKey:@"nodeName"]isEqualToString:@"headers"]) {
                        // ---> 2.4 do headers
                        NSArray *headers = [urlChild objectForKey:@"nodeChildArray"];
                        
                        NSMutableDictionary *parsingHeaders = [[NSMutableDictionary alloc]init];
                        
                        for (NSDictionary *header in headers) {
                            //ParsingHeader * parsingHeader = [[ParsingHeader alloc]init];
                            // NSLog(@"header key %@",[[[header objectForKey:@"nodeAttributeArray"] objectAtIndex:0]objectForKey:@"nodeContent"]);
                            //NSLog(@"header content %@",[header objectForKey:@"nodeContent"]);
                            [parsingHeaders setObject:[header objectForKey:@"nodeContent"] forKey:[[[header objectForKey:@"nodeAttributeArray"] objectAtIndex:0]objectForKey:@"nodeContent"]];
                        }
                        parsingUrl.headers = parsingHeaders;
                        continue;
                        
                        
                    }else if([[urlChild objectForKey:@"nodeName"]isEqualToString:@"fields"]){
                        NSArray *fields = [urlChild objectForKey:@"nodeChildArray"];
                        parsingUrl.fields = [ParsingObject createParsingField:fields];
                        // NSLog(@"field %@",urlChild);
                        
                        
                    }else{
                        // unknown parsing error
                    }
                    // NSArray *fields = [object objectForKey:@"fields"];
                    
                    
                }
                
                
                [[parsingSource urls] addObject:parsingUrl];
            }
            [[parsingObject sources] addObject:parsingSource];
        }
        [pool addObject:parsingObject];
    }
    
    
    NSLog(@" %@ ",pool);
    
    
    // 3. preparation work (part of parser)
    // sort objects by priority
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    [pool sortUsingDescriptors:[NSArray arrayWithObject:sort] ];
    // sort sources by priority
    for (ParsingObject *obj in pool) {
        NSSortDescriptor *sortsources = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
        [obj.sources sortUsingDescriptors:[NSArray arrayWithObject:sortsources] ];
        // sort urls by steps // in main
        for (ParsingSource *src in obj.sources) {
            NSSortDescriptor *sorturl = [NSSortDescriptor sortDescriptorWithKey:@"step" ascending:YES];
            [src.urls sortUsingDescriptors:[NSArray arrayWithObject:sorturl] ];
            
        }
        
    }
    
    
    return pool;
    
}

@end
