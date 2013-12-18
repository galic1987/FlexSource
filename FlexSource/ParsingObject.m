//
//  ParsingObject.m
//  FlexSource
//
//  Created by Ivo Galic on 9/16/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "ParsingObject.h"

@implementation ParsingObject
@synthesize name,type,priority,loading,sources,lastUpdate,message,status,delegate;
@synthesize webview = _webview;


-(void)main{
    if(log) NSLog(@"executing object with resourceId %@",name);
    
    
    status = @"executing";
    // 0.1 Create the object dynamically
    NSObject * dynoObject;
    
    
    // to be done dependencies maybe in future
    for (ParsingSource *src in self.sources) {
        for (ParsingURL *url in src.urls) {
            //NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            //[queue setMaxConcurrentOperationCount:1];
            
            // 1. build request
            // ****************** MISSING OHTER PARAMETERES (timeout, request type etc) TBD
            status = @"request";
            
            if(log) NSLog(@"making request with resourceId %@ : url - %@",name,url.uri);
            
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
            
            if (log) {
                         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                NSLog(@"%i",[httpResponse statusCode]);
            }
            
            
            // js support and without
         //   [self webview];
         //   [_webview loadRequest:request];
            
            
            // 4. finish put it to fields
            if (error == nil)
            {
                // Parse data here
                status = @"parsing";
                
                
                // 4.2 Go throught the fiedls und update dynamically
                 dynoObject = [ParsingObject parsing:data withFields:url.fields klass:self.type withXpathCtx:NULL];

                
                
                // X 4.3 Notify delegate url finished
                
            }else{
                //  ERROR HANDLING
                
                if (log) {
                    NSLog(@"Parser error %@",[error localizedDescription]);
                }
                
                status = @"requestError";
                [delegate errorOnObjectWithId:name theObject:nil withStatus:status withMessage:[error localizedDescription]];
                
                
            }
            
            
            
        }
        // 5. Notify delegate source finished
        
    }
    
    // 6. Notify delegate object finished
    // send resource ID (key)
    // dynoobject (object)
    // send status (
    // send message (
    // set date
    if(log) NSLog(@"returning finished object with resourceId %@",name);
    status = @"finished";
    lastUpdate = [NSDate date];
    [delegate finishedObjectWithId:name theObject:dynoObject withStatus:status withMessage:@"OK"];
    
    
    
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
        NSString *yourHTMLSourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    NSLog(@"%@",yourHTMLSourceCodeString);
}



+ (NSObject*) parsing:(NSData*)document withFields:(NSArray*)fields klass:(NSString*)klass  withXpathCtx:(xmlXPathContextPtr)xpathCtx{
    
    xmlDocPtr doc;
    
    // 0. get object
   // NSObject * object = *objectPtr;
    NSObject * object = [[NSClassFromString(klass) alloc] init];

    if(log) NSLog(@"RAW DATA %@",[NSString stringWithUTF8String:[document bytes]]);
    /* Load XML document */
    if (xpathCtx == NULL) {
        doc = htmlReadMemory([document bytes], [document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    }else{
        doc = xpathCtx->doc;
    }
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	//NSArray *result = PerformXPathQuery(doc, query);
    //xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
    /* Create xpath evaluation context */
    if (xpathCtx == NULL) {
        xpathCtx = xmlXPathNewContext(doc);
    }
    
    
    if(xpathCtx == NULL)
	{
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
    
    // 1. start loop
   
    for (id field in fields) {
        // check if filed or arrayfield
        if([field isKindOfClass:[ParsingField class]]){
            // 2 if field query one take one

            ParsingField *parsingField = field;
            
            xpathObj = xmlXPathEvalExpression((xmlChar *)[parsingField.xpath  cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
            
            if(xpathObj == NULL) {
                NSLog(@"Unable to evaluate XPath.");
                return nil;
            }
            
            xmlNodeSetPtr nodes = xpathObj->nodesetval;
            if (!nodes)
            {
                NSLog(@"Nodes was nil.");
                return nil;
            }
            
            for (NSInteger i = 0; i < nodes->nodeNr; i++)
            {
                
                xmlNodePtr currentNode = nodes->nodeTab[i];
                
                if (currentNode->name)
                {
                    NSString *currentNodeContent =
                    [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
                    
                    NSLog(@"Node name ***** %@",currentNodeContent);
                }

                //NSLog(@"***** %@",currentNode->type);
                
                if (currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE)
                {
                    NSString *currentNodeContent =
                    [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];
                    NSLog(@"Node Content ***** %@",currentNodeContent);
                    // other object types to come -> pictures etc
                    [object setValueForObjectDirect:currentNodeContent fieldName:parsingField.name classPropsFor:[object class] obj:object];
                    break;
                    
                }
                
                xmlAttr *attribute = currentNode->properties;
                if (attribute)
                {
                    NSMutableArray *attributeArray = [NSMutableArray array];
                    while (attribute)
                    {
                        NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
                        NSString *attributeName =
                        [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
                        if (attributeName)
                        {
                            [attributeDictionary setObject:attributeName forKey:@"attributeName"];
                        }
                        
                        if (attribute->children)
                        {
                            //NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary);
                            //if (childDictionary)
                           // {
                                //[attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
                           // }
                        }
                        
                        if ([attributeDictionary count] > 0)
                        {
                            [attributeArray addObject:attributeDictionary];
                        }
                        attribute = attribute->next;
                    }
                    
                    if ([attributeArray count] > 0)
                    {
                        //[resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
                    }
                }
                
                xmlNodePtr childNode = currentNode->children;
                if (childNode)
                {
                    NSMutableArray *childContentArray = [NSMutableArray array];
                    while (childNode)
                    {
                       // NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode);
//                        if (childDictionary)
//                        {
//                            [childContentArray addObject:childDictionary];
//                        }
//                        childNode = childNode->next;
                    }
                    if ([childContentArray count] > 0)
                    {
                       // [resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
                    }
                }

                
                
                
                
//                else{
//                    NSLog(@"ERROR UNKNOWN");
//                    if(log) NSLog(@"cannot find xpath value for field %@ with value %@",parsingField.name,parsingField.xpath);
//                    
//                }
            }
            
        }else{
            // 3 if fieldarray query one xpath iterate all fields xpath (create array + object to fill)
            ParsingFieldArray *p = field;
            // for now only NSMutableArray
            
            // add dynamic ?
            NSMutableArray *ar = [NSMutableArray array];
            [object setValue:ar forKey:p.name];
            
            // fill array with objects
            // ---> fill each field with xpath query context
            NSArray * newFields = p.fieldArray;
            
            xpathObj = xmlXPathEvalExpression((xmlChar *)[p.xpath  cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
            
            if(xpathObj == NULL) {
                NSLog(@"Unable to evaluate XPath.");
                return nil;
            }
            
            //iteriraj rezultate od noda salji i vracaji dodaji u array!!!
            
            xmlNodeSetPtr nodes = xpathObj->nodesetval;
            if (!nodes)
            {
                NSLog(@"Nodes was nil.");
                return nil;
            }
            
            for (NSInteger i = 0; i < nodes->nodeNr; i++)
            {
                
                xmlNodePtr currentNode = nodes->nodeTab[i];

                xmlXPathContextPtr xpContext = xmlXPathNewContext((xmlDocPtr)currentNode);
                
                NSObject * recursionIncoming = [ParsingObject parsing:document withFields:p.fieldArray klass:p.type withXpathCtx:xpContext];
                
                // add it to array
                [ar addObject:recursionIncoming];
                
            
            }
            
            
        }
    }
    
   
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    xmlFreeDoc(doc);
    return object;
    
    
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
            if(log) NSLog(@"field content %@",[field objectForKey:@"nodeContent"]);
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
                   if(log) NSLog(@"xpath content %@",[arrayFieldChild objectForKey:@"nodeContent"]);
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


#pragma mark - accessors

- (void)setWebview:(UIWebView *)webview {
    @synchronized(self) {
        _webview = webview;
        webview.delegate = self;
    }
}

- (UIWebView*)webview {
    @synchronized(self) {
        if (!_webview) {
            if ([NSThread isMainThread]) {
                _webview = [[UIWebView alloc] init];
                _webview.delegate = self;
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    _webview = [[UIWebView alloc] init];
                    _webview.delegate = self;
                });
            }
        }
    }
    return _webview;
}



@end
