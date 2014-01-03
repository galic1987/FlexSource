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
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            {
                if (error == nil){
                    NSObject* dynoObject;

                    
                    if (url.javascript < 1) {
                        // 3.1 if js disabled just start parsing
                        if (log) {
                            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                            NSLog(@"%i",[httpResponse statusCode]);
                        }
                        
                        
                    }else{
                        // 3.2 if js enabled load webview and wait time for load
                        // js support and without
                        [self webview];
                        
                        [_webview  loadData:data MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:uri];
                        //[_webview loadRequest:request];
                        NSDate *wait = [NSDate dateWithTimeIntervalSinceNow:url.waitJSComputation];
                        
                        [[NSRunLoop currentRunLoop] runUntilDate:wait];
                        
                        NSString *newData = [_webview stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
                        data =  [newData dataUsingEncoding:NSUTF8StringEncoding];
                        
                    }
                    
                    // Parse data here
                    status = @"parsing";

                    // 4.2 Go throught the fiedls und update dynamically
                    dynoObject = [ParsingObject parsing:data withFields:url.fields klass:self.type withXpathCtx:NULL];
                    
                    if (dynoObject == nil) {
                        // 3.3 error
                        
                        status = @"ParserError";
                        if (log) {
                            NSLog(@"Parser error object is nil");
                        }
                        
                        if ([type isEqualToString:@"Test"]) {
                            // this is test so return test failed
                            [delegate testResultOnObject:nil result:NO msg:@"Test failed to build object"];
                            return ;
                        }
                        
                        [delegate errorOnObjectWithId:name theObject:nil withStatus:status withMessage:@"Parser failed to build object"];
                        return;
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
                    
                    // test finish
                    if ([type isEqualToString:@"Test"]) {
                        NSMutableArray *testObjects = (NSMutableArray *)dynoObject;
                        
                        
                        [delegate testResultOnObject:testObjects result:YES msg:@"Test"];

                    }else{
                        // normal finish
                        [delegate finishedObjectWithId:name theObject:dynoObject withStatus:status withMessage:@"OK"];
                    }
                    
                    
                }else {
                    
                    // 3.3 error
                    if (log) {
                        NSLog(@"Request error %@",[error localizedDescription]);
                    }
                    
                    status = @"requestError";
                    
                    if ([type isEqualToString:@"Test"]) {
                        // this is test so return test failed
                        [delegate testResultOnObject:nil result:NO msg:[error localizedDescription]];
                        return ;
                    }
                    
                    [delegate errorOnObjectWithId:name theObject:nil withStatus:status withMessage:[error localizedDescription]];
                }
            }];
             /*   NSData * data = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&_response
                                                              error:&_error];
            */
            
            
            
            
            
            
            
            // 4. finish put it to fields
            
            
            
        }
        // 5. Notify delegate source finished
        
    }
    
    
}

#pragma mark content finished loading
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
        NSString *yourHTMLSourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
   // NSLog(@"****** %@",yourHTMLSourceCodeString);
}





#pragma mark parser

+ (NSObject*) parsing:(NSData*)document withFields:(NSArray*)fields klass:(NSString*)klass  withXpathCtx:(xmlXPathContextPtr)xpathCtx{
    
    xmlDocPtr doc;
    BOOL root;
    
    // 0. get object
   // NSObject * object = *objectPtr;
    NSObject * object = nil;
    NSMutableArray *testArray = nil;
    
    if ([klass isEqualToString:@"Test"]) {
        object = [[ParsingTest alloc]init];
        testArray = [NSMutableArray array];
    }else{
        object = [[NSClassFromString(klass) alloc] init];
    }

    //if(log) NSLog(@"RAW DATA %@",[NSString stringWithUTF8String:[document bytes]]);
    /* Load XML document */
    if (xpathCtx == NULL) {
        root = YES;
        doc = htmlReadMemory([document bytes], [document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    }else{
        doc = xpathCtx->doc;
        root = NO;

    }
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
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
               // printCurrentNode(doc, currentNode);

                if (currentNode->name)
                {
                    NSString *currentNodeContent =
                    [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
                    
                   if(log) NSLog(@"Node name ***** %@",currentNodeContent);
                }

                //NSLog(@"***** %@",currentNode->type);
                
                if (currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE)
                {
                    NSString *currentNodeContent =
                    [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];
                    if (log) NSLog(@"Node Content ***** %@",currentNodeContent);
                    
                    /// TESTING PROCEDURE
                    if ([klass isEqualToString:@"Test"]) {
                        // do testing return
                        
                        //                            // collect following data: date, current parsing object, current & expected value, xpath Buffer, give it to ParsingTest
                        ParsingTest *testObject = (ParsingTest*)object;
                        testObject.date = [NSDate date];
                        testObject.expectedValue = parsingField.expectedValue;
                        testObject.xpath = parsingField.xpath;
                        testObject.currentValue = currentNodeContent;
                        testObject.xpathParsingBuffer = getCurrentNodeBuffer(doc, currentNode);

                        if ([testObject.currentValue isEqualToString:testObject.expectedValue]) {
                            testObject.result = @"OK";
                        }else{
                            testObject.result = @"FAIL";
                        }
                        
                        
                        [testArray addObject:testObject];
                        
                        break;
                        
                    }else{
                        // Standard dynamic assigment to objects
                        // other object types to come -> pictures etc
                        [object setValueForObjectDirect:currentNodeContent fieldName:parsingField.name classPropsFor:[object class] obj:object];
                        break;
                    }
                    
                }
                
               /* 
                
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


                }
                
                */

                
                
                
                
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
            
            
            
            // implement offset
            int start = 0;
            int end = nodes->nodeNr;
            
            if (p.startOffset != 0) {
                start = p.startOffset;
            }
            
            if (p.endOffset != 0) {
                end = p.endOffset;
                if (nodes->nodeNr < p.endOffset) {
                    end =nodes->nodeNr;
                    NSLog(@"EndOffset too large setting to actual result number to avoid array overflow");
                }
            }
            
            
            
            // result loop
            for (NSInteger i = start; i < end; i++)
            {
                
                xmlNodePtr currentNode = nodes->nodeTab[i];

                
                printCurrentNode(doc, currentNode);
                
               // xmlXPathContextPtr xpContext = xmlXPathNewContext(currentNode->doc);
                // save node
                xmlNodePtr save = xpathCtx->node;
                xpathCtx->node = currentNode;
                
                NSObject * recursionIncoming = [ParsingObject parsing:document withFields:newFields klass:p.type withXpathCtx:xpathCtx];
                
               // xmlXPathFreeContext(xpContext);
                xpathCtx->node = save;

                
                // add it to array
                if (recursionIncoming!=nil) {
                    [ar addObject:recursionIncoming];

                }
                
                
            
            }
            
            
        }
    }
    
    if(root){
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    xmlFreeDoc(doc);
    }
    
    if ([klass isEqualToString:@"Test"]) {
        return (NSObject*)testArray;
    }

    return object;
    
    
}

// needed for debugging
void printCurrentNode(xmlDocPtr doc, xmlNodePtr node){
    xmlBufferPtr nodeBuffer = xmlBufferCreate();
    xmlNodeDump(nodeBuffer, doc, node, 0, 1);
    // ... Do something with nodeBuffer->content
    NSString *currentNodeContent = nil;
    
    if (nodeBuffer->content )
    {
        currentNodeContent =
        [NSString stringWithCString:(const char *)nodeBuffer->content encoding:NSUTF8StringEncoding];
        NSLog(@"Node Content ***** %@",currentNodeContent);
        
        
    }
    xmlBufferFree(nodeBuffer);
}

NSString* getCurrentNodeBuffer(xmlDocPtr doc, xmlNodePtr node){
    xmlBufferPtr nodeBuffer = xmlBufferCreate();
    xmlNodeDump(nodeBuffer, doc, node, 0, 1);
    // ... Do something with nodeBuffer->content
    NSString *currentNodeContent = nil;
    
    if (nodeBuffer->content )
    {
        currentNodeContent =
        [NSString stringWithCString:(const char *)nodeBuffer->content encoding:NSUTF8StringEncoding];
        NSLog(@"Node Content ***** %@",currentNodeContent);
        
        
    }
    xmlBufferFree(nodeBuffer);
    return currentNodeContent;
}



#pragma mark - accessors
// needed for javascript load
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
