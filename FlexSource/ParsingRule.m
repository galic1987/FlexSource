//
//  ParsingRule.m
//  FlexSource
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "ParsingRule.h"

@implementation ParsingRule

@synthesize url,dateDownloaded,md5Hash,parsingError,parsingStatus,type,ruleRaw,v,log;



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

void handleValidationError(void *ctx, const char *format, ...) {
    char *errMsg;
    va_list args;
    va_start(args, format);
    vasprintf(&errMsg, format, args);
    va_end(args);
    fprintf(stderr, "Validation Error: %s", errMsg);
    free(errMsg);
}

+(BOOL)validateRule:(NSData*)ruleData withSchema:(NSData*)schemaData{
    
    int result = 42;
    xmlSchemaParserCtxtPtr parserCtxt = NULL;
    xmlSchemaPtr schema = NULL;
    xmlSchemaValidCtxtPtr validCtxt = NULL;
    
    //xmlDocPtr xmlDocumentPointer = xmlParseMemory(xmlSource, xmlLength);
    
    xmlDocPtr xmlDocumentPointer = xmlReadMemory([ruleData bytes], [ruleData length], "", NULL, XML_PARSE_RECOVER);
    
    
    parserCtxt = xmlSchemaNewMemParserCtxt([schemaData bytes],[schemaData length]);
    //parserCtxt = xmlSchemaNewParserCtxt([schemaData bytes]);
    
    if (parserCtxt == NULL) {
        fprintf(stderr, "Could not create XSD schema parsing context.\n");
        
        goto leave;
    }
    
    schema = xmlSchemaParse(parserCtxt);
    
    if (schema == NULL) {
        fprintf(stderr, "Could not parse XSD schema.\n");
        goto leave;
    }
    
    validCtxt = xmlSchemaNewValidCtxt(schema);
    
    if (!validCtxt) {
        fprintf(stderr, "Could not create XSD schema validation context.\n");
        goto leave;
    }
    
    xmlSetStructuredErrorFunc(NULL, NULL);
    xmlSetGenericErrorFunc(NULL, handleValidationError);
    xmlThrDefSetStructuredErrorFunc(NULL, NULL);
    xmlThrDefSetGenericErrorFunc(NULL, handleValidationError);
    
    result = xmlSchemaValidateDoc(validCtxt, xmlDocumentPointer);
    
leave:
    
    if (parserCtxt) {
        xmlSchemaFreeParserCtxt(parserCtxt);
    }
    
    if (schema) {
        xmlSchemaFree(schema);
    }
    
    if (validCtxt) {
        xmlSchemaFreeValidCtxt(validCtxt);
    }
    printf("\n");
    printf("Validation successful: %s (result: %d)\n", (result == 0) ? "YES" : "NO", result);
    
    return (result == 0) ? YES : NO;
}



+(NSMutableArray*)parseRule:(NSData*)content{
    
   // DLog(@"Content: %@", content);
    
    
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
    NSArray *objects = PerformXMLXPathQuery(content, @"//ns:objects/ns:object");
    for (NSDictionary *object in objects) {
        // ---> 2.1 start another loop sources for each object -- sort by priority
        ParsingObject * parsingObject = [[ParsingObject alloc]init];
        parsingObject.sources = [NSMutableArray array];
        
        //[parsingObject setAttributesForObject:[object objectForKey:@"nodeAttributeArray"]];
        [parsingObject setAttributesForObject:[object objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingObject class] obj:parsingObject];
        
        //DLog(@"OOO %@",parsingObject.name);
        
        NSArray *sources = [object objectForKey:@"nodeChildArray"];
        for (NSDictionary *source in sources) {
            ParsingSource *parsingSource = [[ParsingSource alloc]init];
            parsingSource.urls = [NSMutableArray array];
            [parsingSource setAttributesForObject:[source objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingSource class] obj:parsingSource];
            
            //DLog(@"111 %@",source);
            // ---> 2.2 start another loop urls for each soruce -- sort by steps
            NSArray *urls = [source objectForKey:@"nodeChildArray"];
            
            for (NSDictionary *url in urls) {
                ParsingURL * parsingUrl = [[ParsingURL alloc]init];
                [parsingUrl setAttributesForObject:[url objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingURL class] obj:parsingUrl];
                
                
                
                //DLog(@"222 %@",url);
                NSArray *urlChilds = [url objectForKey:@"nodeChildArray"];
                // ---> 2.3 start another loop fields for each object
                for (NSDictionary *urlChild in urlChilds) {
                    if ([[urlChild objectForKey:@"nodeName"]isEqualToString:@"headers"]) {
                        // ---> 2.4 do headers
                        NSArray *headers = [urlChild objectForKey:@"nodeChildArray"];
                        
                        NSMutableDictionary *parsingHeaders = [[NSMutableDictionary alloc]init];
                        
                        for (NSDictionary *header in headers) {
                            //ParsingHeader * parsingHeader = [[ParsingHeader alloc]init];
                            // DLog(@"header key %@",[[[header objectForKey:@"nodeAttributeArray"] objectAtIndex:0]objectForKey:@"nodeContent"]);
                            //DLog(@"header content %@",[header objectForKey:@"nodeContent"]);
                            [parsingHeaders setObject:[header objectForKey:@"nodeContent"] forKey:[[[header objectForKey:@"nodeAttributeArray"] objectAtIndex:0]objectForKey:@"nodeContent"]];
                        }
                        parsingUrl.headers = parsingHeaders;
                        continue;
                        
                        
                    }else if([[urlChild objectForKey:@"nodeName"]isEqualToString:@"fields"]){
                        NSArray *fields = [urlChild objectForKey:@"nodeChildArray"];
                        parsingUrl.fields = [ParsingRule
                                             createParsingField:fields];
                        // DLog(@"field %@",urlChild);
                        
                        
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
    
    
    //if (log) DLog(@"Objects in pool %@ ",pool);
    
    
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


// move to Parsing Rule
+ (NSMutableArray*) createParsingField:(NSArray*)fields{
    /// recursive part start
    NSMutableArray *myFields = [[NSMutableArray alloc]init];
    for (NSDictionary *field in fields) {
        // ---> 2.5 start another loop array for type array field
        //NSArray *field = [field objectForKey:@"fields"];
        //for (NSDictionary *field in fields) {
        //DLog(@"add field %@",field);
        if ([[field objectForKey:@"nodeName"]isEqualToString:@"field"]) {
            //if(log) DLog(@"field content %@",[field objectForKey:@"nodeContent"]);
            ParsingField *pf = [[ParsingField alloc]init];
            [pf setAttributesForObject:[field objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingField class] obj:pf];
            pf.xpath =[field objectForKey:@"nodeContent"];
            [myFields addObject:pf];
            
        }else if([[field objectForKey:@"nodeName"]isEqualToString:@"arrayfield"]) {
            ParsingFieldArray *pfa = [[ParsingFieldArray alloc]init];
            // pfa.fieldArray = [NSMutableArray array];
            [pfa setAttributesForObject:[field objectForKey:@"nodeAttributeArray"] classPropsFor:[ParsingFieldArray class] obj:pfa];
            
            NSArray *arrayFields = [field objectForKey:@"nodeChildArray"];
            for (NSDictionary *arrayFieldChild in arrayFields) {
                
                
                if ([[arrayFieldChild objectForKey:@"nodeName"]isEqualToString:@"xpath"]) {
                    //if(log) DLog(@"xpath content %@",[arrayFieldChild objectForKey:@"nodeContent"]);
                    pfa.xpath =[arrayFieldChild objectForKey:@"nodeContent"];
                }else if([[arrayFieldChild objectForKey:@"nodeName"]isEqualToString:@"arrayobject"]) {
                    // ------> recursive field call
                    //DLog(@"%@",[arrayFieldChild objectForKey:@"nodeChildArray"]);
                    
                    pfa.fieldArray = [ParsingRule createParsingField:[arrayFieldChild objectForKey:@"nodeChildArray"]];
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
