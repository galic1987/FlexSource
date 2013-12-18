//
//  FlexSourceTests.m
//  FlexSourceTests
//
//  Created by Ivo Galic on 9/15/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "FlexSourceTests.h"
//UIApplication *delegate;


   UIApplication       *app;
@implementation FlexSourceTests



- (void)setUp
{
    
    
       app                  = [UIApplication sharedApplication];

    [super setUp];
    
    // Set-up code here.
   // delegate = [[UIApplication sharedApplication] delegate];

}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


-(void)testFlexSource{
    
  //  UIWebView *ui = [[UIWebView alloc]init];
    STAssertNotNil(app, @"UIApplication failed to find the AppDelegate");

    
    
    FlexSource *fx = [[FlexSource alloc]initWithRuleUrl:nil];
    fx.log = YES;
    [fx updateRules];
    
    
    
    NSDate *fiveSecondsFromNow = [NSDate dateWithTimeIntervalSinceNow:15.0];
    
    fx.delegate = self;
    // delegate method include
    [fx parse];
    
    [[NSRunLoop currentRunLoop] runUntilDate:fiveSecondsFromNow];

    
}


-(void)finishedObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message{
        NSLog(@"TS %@%@%@%@",resourceID,object,status,message);
    
    // indirect
    // 1. getObject from dictionary with objectId after some flag
    // 2. autoconnect etc...
    
    // direct
    // 1. cast object to expected object and connect to gui
    // 2. autoconnect gui via samenaming mechanism setter
}

-(void)errorOnObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message{
    
        NSLog(@"TS %@%@%@%@",resourceID,object,status,message);
    
}









- (void)testXMLStructureParser
{
    return;
    NSString *path = [[NSBundle bundleForClass:[self class] ] pathForResource:@"example_rule" ofType:@"xml"];
    NSData *xmlData = [NSData dataWithContentsOfFile:path];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];

    NSArray *objects = [doc nodesForXPath:@"objects/object" error:nil];

    for (GDataXMLElement *object in objects) {
        NSArray *sources = [object nodesForXPath:@"source" error:nil];
        for (GDataXMLElement *source in sources) {
            NSArray *urls = [source nodesForXPath:@"url" error:nil];
            for (GDataXMLElement *url in urls) {
                // call every source
                
                // get url for 
                GDataXMLNode *uri = [url attributeForName:@"uri"];
                NSLog(@"++++++ %@",uri.stringValue );
                STAssertEqualObjects(uri.stringValue, @"https://addons.mozilla.org/en-us/firefox/addon/firepath/", @"Uri test");
                
                // get step number
                GDataXMLNode *step = [url attributeForName:@"step"];
                NSLog(@"++++++ %@",step.stringValue );
                STAssertEqualObjects(step.stringValue, @"1", @"Step number test");
                
                // get headers
                GDataXMLNode *headersRoot = [[url nodesForXPath:@"headers" error:nil] objectAtIndex:0];
                NSArray *headers = [headersRoot nodesForXPath:@"header" error:nil];
                for (GDataXMLElement *header in headers) {
                    NSString *key = [header attributeForName:@"key"].stringValue;
                    NSString *value = header.stringValue;
                    STAssertEqualObjects(key, @"User-Agent", @"Header Key test");
  //                  STAssertEqualObjects(value, @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:24.0) Gecko/20100101 Firefox/24.0", @"Header Key test");
                }
                
                // get fields
                GDataXMLNode *fieldsRoot = [[url nodesForXPath:@"fields" error:nil] objectAtIndex:0];
                NSArray *fields = [fieldsRoot nodesForXPath:@"field" error:nil];
                for (GDataXMLElement *field in fields) {
                  //  NSString *name = [field attributeForName:@"name"].stringValue;
                  //  NSString *type = [field attributeForName:@"type"].stringValue;
                    NSString *xpath = field.stringValue;
                    
                    NSLog(@"%@",xpath);
//                    STAssertEqualObjects(key, @"User-Agent", @"Header Key test");
//                    STAssertEqualObjects(value, @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:24.0) Gecko/20100101 Firefox/24.0", @"Header Key test");
                    
                    
                }

                
                return;
                
                NSLog(@"%@",url );
            }
        }
    }

}


- (void)testHTMLParsing
{
    
    return;
    NSString* file = [[NSBundle bundleForClass:[self class] ] pathForResource:@"example_rule" ofType:@"xml"];
    
    // full unit [NSBundle mainBundle] 
    //NSString *file=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"example_rule.xml"];
    NSError *error = nil;
    
    NSString* content = [NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    NSLog(@"File: %@", file);
    NSLog(@"Content: %@", content);

    HTMLParser *parser = [[HTMLParser alloc] initWithString:content error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        //STFail(@"Cannot open the file");
    }
    
    HTMLNode *bodyNode = [parser body];
    
    // get objects 
    NSArray *inputNodes = [bodyNode findChildTags:@"object"];
    
    
    
    for (HTMLNode *inputNode in inputNodes) {
        
        NSArray *sourcesArray =  [inputNode findChildTags:@"source"];
        
        for (HTMLNode *urls in sourcesArray) {
            NSLog(@"%@",[urls contents] );

            NSArray *urlArray =  [urls findChildTags:@"url"];
            
            for (HTMLNode *urlInner in urlArray) {
                HTMLNode *fields = [urlInner findChildTags:@"field"];

                NSArray *fieldsArray =  [urlInner findChildTags:@"fields"];

                
            } 
        }

        
//        if ([[inputNode getAttributeNamed:@"name"] isEqualToString:@"input2"]) {
//            NSLog(@"%@", [inputNode getAttributeNamed:@"value"]); //Answer to first question
//        }
    }
    
//    NSArray *spanNodes = [bodyNode findChildTags:@"span"];
//    
//    for (HTMLNode *spanNode in spanNodes) {
//        if ([[spanNode getAttributeNamed:@"class"] isEqualToString:@"spantext"]) {
//            NSLog(@"%@", [spanNode allContents]); //Answer to second question
//        }
//    }

    // get rules file from rules database
    // create objectpool with rules file
    // start receiving objects synchro
    // parse objects with xpath
    //
    
    
}



-(void)testClassDynamicProperties{
    return;
   NSDictionary *d= [PropertyUtil classPropsFor:[ClassTestExample class]];
    
    
    ClassTestExample *c = [[ClassTestExample alloc]init];
    c.test = @"dsad";
    
    
    for (NSString * key in d) {
        if (true) { //matching key
            [c setValue:d[key] forKey:key ];
        }
    }
    NSLog(@"%@",c.test);
    NSLog(@"%@",d);

    STAssertEqualObjects(c.test, @"NSString", @"Must be NSString");

    
}


-(void)testXPath{
    return;
    NSString *urlAsString = @"https://addons.mozilla.org/en-us/firefox/addon/firepath/";
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];
    /* Return Value
     The downloaded data for the URL request. Returns nil if a connection could not be created or if the download fails.
     */
    if (response == nil) {
        // Check for problems
        if (requestError != nil) {

        }
    }
    else {
        //NSArray *tdNodes = PerformHTMLXPathQuery(response, @"//*[@id='addon'][1]");
        NSArray *tdNodes = PerformHTMLXPathQuery(response, @"//h1/a");
       // NSLog(@"%@",[[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding] );
       // NSArray *di = [tdNodes objectForKey:@"nodeAttributeArray"];
        
        /*
         nodeName — an NSString containing the name of the node
         nodeContent — an NSString containing the textual content of the node
         nodeAttributeArray — an NSArray of NSDictionary where each dictionary has two keys: attributeName (NSString) and nodeContent (NSString)
         nodeChildArray — an NSArray of child nodes (same structure as this node)
         */
        
        
        
       
        for (NSDictionary *ns in tdNodes) {
//            NSLog(@"nodeName ++ %@",[ns objectForKey:@"nodeName"]);
            STAssertEqualObjects([ns objectForKey:@"nodeName"], @"a", @"test");
//            NSLog(@"nodeContent +++ %@",[ns objectForKey:@"nodeContent"]);
//            NSLog(@"nodeAttributeArray +++ %@",[ns objectForKey:@"nodeAttributeArray"]);
//            NSLog(@"nodeChildArray +++ %@",[ns objectForKey:@"nodeChildArray"]);
            
        }
        

    }
    
    
    
   }


-(void)testArrayParsing{
    return;
    NSString *urlAsString = @"https://addons.mozilla.org/en-us/firefox/addon/firepath/";
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];
    /* Return Value
     The downloaded data for the URL request. Returns nil if a connection could not be created or if the download fails.
     */
    if (response == nil) {
        // Check for problems
        if (requestError != nil) {
            
        }
    }
    else {
        //NSArray *tdNodes = PerformHTMLXPathQuery(response, @"//*[@id='addon'][1]");
        NSArray *tdNodes = PerformHTMLXPathQuery(response, @"//span");
        // NSLog(@"%@",[[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding] );
        // NSArray *di = [tdNodes objectForKey:@"nodeAttributeArray"];
        
        /*
         nodeName — an NSString containing the name of the node
         nodeContent — an NSString containing the textual content of the node
         nodeAttributeArray — an NSArray of NSDictionary where each dictionary has two keys: attributeName (NSString) and nodeContent (NSString)
         nodeChildArray — an NSArray of child nodes (same structure as this node)
         */
        
        
        
        
        for (NSDictionary *ns in tdNodes) {
//            NSLog(@"nodeName ++ %@",[ns objectForKey:@"nodeName"]);
           // STAssertEqualObjects([ns objectForKey:@"nodeName"], @"a", @"test");
//            NSLog(@"nodeContent +++ %@",[ns objectForKey:@"nodeContent"]);
//            NSLog(@"nodeAttributeArray +++ %@",[ns objectForKey:@"nodeAttributeArray"]);
//            NSLog(@"nodeChildArray +++ %@",[ns objectForKey:@"nodeChildArray"]);
            NSLog(@"xmlXPathContextPtr ++ %@",[ns objectForKey:@"xmlXPathContextPtr"]);

        }
        
        
    }
    

}

-(void)testParsingBeta{
    return;
    NSString* file = [[NSBundle bundleForClass:[self class] ] pathForResource:@"example_rule" ofType:@"xml"];
    
    // full unit [NSBundle mainBundle]
    //NSString *file=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"example_rule.xml"];
    NSError *error = nil;
    NSData *content = [NSData dataWithContentsOfFile:file];
//    NSString* content = [NSString stringWithContentsOfFile:file
//                                                  encoding:NSUTF8StringEncoding
//                                                     error:nil];
    NSLog(@"File: %@", file);
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

    
    
    // Object pool execution parser - in pool

    // 4. parsing in the queue (refresh action/ reload sources starts here)
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:1];
    

    
    for (ParsingObject *obj in pool) {
        if ([obj.name isEqualToString:@"NSIvoObject"]) {
            [obj main];
        }
        NSLog(@"%@",obj.name);
    //[queue addOperation:obj];
    }
    
    
    
}





@end
