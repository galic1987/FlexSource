//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "XPathQuery.h"


@implementation XPathQuery




NSArray *PerformRuleReading(xmlDocPtr doc, xmlDocPtr rule, NSString *query)
{
    
    // Summary
    // parsing style singlethreaded sequential blocking

    // in rule object (XML)
    // in doc object (HTML)
    // out NSArray of objects
    
    // 1. parser version == file version otherwise error
    
    // 2. each object in loop xpath query -- sort by priority
    // ---> 2.1 start another loop sources for each object -- sort by priority
    // ---> 2.2 start another loop urls for each soruce -- sort by steps
    // ---> 2.3 start another loop fields for each object
    // ---> 2.4 start another loop array for type array field
    
    // 3. push object to object pool - sigleton
    
    
    
    
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    
    
    if(xpathCtx == NULL)
	{
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
		return nil;
    }
    
    //    xmlChar *c1 = (xmlChar *)xpathObj->stringval;
    //
    //    if (c1) {
    //        NSLog(@"******%@",[NSString stringWithCString:(char * const)c1 encoding:NSUTF8StringEncoding]);
    //    }
    
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes)
	{
		NSLog(@"Nodes was nil.");
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++)
	{
		NSMutableDictionary *nodeDictionary = (NSMutableDictionary*)DictionaryForNode(nodes->nodeTab[i], nil);
        
        xmlXPathContextPtr xpContext = xmlXPathNewContext((xmlDocPtr)nodes->nodeTab[i]);
        //        xpContext->doc
        NSValue* value = [NSValue value:&xpContext withObjCType:@encode(xmlXPathContextPtr)];
        [nodeDictionary setValue:value forKey:@"xmlXPathContextPtr"];
        
        // call recursevly
		if (nodeDictionary)
		{
			[resultNodes addObject:nodeDictionary];
		}
	}
    
    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    
    return resultNodes;
}





NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult)
{
	NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
	
	if (currentNode->name)
	{
		NSString *currentNodeContent =
			[NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
		[resultForNode setObject:currentNodeContent forKey:@"nodeName"];
	}
	
	if (currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE)
	{
		NSString *currentNodeContent =
			[NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];
		
		if ([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult)
		{
			currentNodeContent = [currentNodeContent
				stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			NSString *existingContent = [parentResult objectForKey:@"nodeContent"];
			NSString *newContent;
			if (existingContent)
			{
				newContent = [existingContent stringByAppendingString:currentNodeContent];
			}
			else
			{
				newContent = currentNodeContent;
			}

			[parentResult setObject:newContent forKey:@"nodeContent"];
			return nil;
		}
		
		[resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
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
				NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary);
				if (childDictionary)
				{
					[attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
				}
			}
			
			if ([attributeDictionary count] > 0)
			{
				[attributeArray addObject:attributeDictionary];
			}
			attribute = attribute->next;
		}
		
		if ([attributeArray count] > 0)
		{
			[resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
		}
	}

	xmlNodePtr childNode = currentNode->children;
	if (childNode)
	{
		NSMutableArray *childContentArray = [NSMutableArray array];
		while (childNode)
		{
			NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode);
			if (childDictionary)
			{
				[childContentArray addObject:childDictionary];
			}
			childNode = childNode->next;
		}
		if ([childContentArray count] > 0)
		{
			[resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
		}
	}
	
	return resultForNode;
}

NSArray *PerformXPathQuery(xmlDocPtr doc, NSString *query)
{
    xmlXPathContextPtr xpathCtx; 
    xmlXPathObjectPtr xpathObj; 

    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    
    
    if(xpathCtx == NULL)
	{
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
		return nil;
    }
    
//    xmlChar *c1 = (xmlChar *)xpathObj->stringval;
//                   
//    if (c1) {
//        NSLog(@"******%@",[NSString stringWithCString:(char * const)c1 encoding:NSUTF8StringEncoding]);
//    }
    
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes)
	{
		NSLog(@"Nodes was nil.");
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++)
	{
		NSMutableDictionary *nodeDictionary = (NSMutableDictionary*)DictionaryForNode(nodes->nodeTab[i], nil);
        
        xmlXPathContextPtr xpContext = xmlXPathNewContext((xmlDocPtr)nodes->nodeTab[i]);
//        xpContext->doc
        NSValue* value = [NSValue value:&xpContext withObjCType:@encode(xmlXPathContextPtr)];
        [nodeDictionary setValue:value forKey:@"xmlXPathContextPtr"];

        // call recursevly
		if (nodeDictionary)
		{
			[resultNodes addObject:nodeDictionary];
		}
	}

    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx); 
    
    return resultNodes;
}




NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query)
{
    xmlDocPtr doc;

    /* Load XML document */
	doc = htmlReadMemory([document bytes], [document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(doc); 
	
	return result;
}

NSArray *PerformXMLXPathQuery(NSData *document, NSString *query)
{
    xmlDocPtr doc;
	
    /* Load XML document */
	doc = xmlReadMemory([document bytes], [document length], "", NULL, XML_PARSE_RECOVER);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(doc); 
	
	return result;
}
@end


