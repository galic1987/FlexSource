//
//  NSObject+FSClassHelper.m
//  FlexSource
//
//  Created by Ivo Galic on 24/11/13.
//  Copyright (c) 2013 Ivo Galic. All rights reserved.
//

#import "NSObject+FSClassHelper.h"

@implementation NSObject (FSClassHelper)


- (void)setAttributesForObject:(NSArray *)ar classPropsFor:(Class)klass obj:(id)object{
    
    NSDictionary *listVarType= [PropertyUtil classPropsFor:klass];
    
    for (NSDictionary *objectp in ar) {
        //dynamically
        for (NSString * key in listVarType) {
                   //     DLog(@"---- %@",listVarType );
            if ([[objectp objectForKey:@"attributeName"]isEqualToString:key]) { //matching key
                if ([[listVarType objectForKey:key]isEqualToString:@"NSString"]) {
                    [object setValue:[objectp objectForKey:@"nodeContent"] forKey:key ];
                }else if([[listVarType objectForKey:key]isEqualToString:@"i"]){
                    int i = [[objectp objectForKey:@"nodeContent"] intValue];
                    [object setValue:[NSNumber numberWithInt:i] forKey:key ];
                    
                }else{
                    // no recognized type
                }
            }
        }
        
    }
    
}



- (void)setValueForObject:(NSDictionary *)value fieldName:(NSString*)fieldName classPropsFor:(Class)klass obj:(id)object{
    
    NSDictionary *listVarType= [PropertyUtil classPropsFor:klass];
    
   // for (NSDictionary *objectp in ar) {
        //dynamically
        for (NSString * key in listVarType) {
            //     DLog(@"---- %@",listVarType );
            if ([fieldName isEqualToString:key]) { //matching key
                if ([[listVarType objectForKey:key]isEqualToString:@"NSString"]) {
                    [object setValue:[value objectForKey:@"nodeContent"] forKey:key ];
                }else if([[listVarType objectForKey:key]isEqualToString:@"i"]){
                    int i = [[value objectForKey:@"nodeContent"] intValue];
                    [object setValue:[NSNumber numberWithInt:i] forKey:key ];
                    
                }else{
                    // no recognized type
                }
            }
        }
        
   // }
    
}


- (void)setValueForObjectDirect:(NSString *)value fieldName:(NSString*)fieldName classPropsFor:(Class)klass obj:(id)object{
    
    NSDictionary *listVarType= [PropertyUtil classPropsFor:klass];
    
    // for (NSDictionary *objectp in ar) {
    //dynamically
    for (NSString * key in listVarType) {
        //     DLog(@"---- %@",listVarType );
        if ([fieldName isEqualToString:key]) { //matching key
            if ([[listVarType objectForKey:key]isEqualToString:@"NSString"]) {
                [object setValue:value forKey:key ];
            }else if([[listVarType objectForKey:key]isEqualToString:@"i"]){
                int i = [value intValue];
                [object setValue:[NSNumber numberWithInt:i] forKey:key ];
                
            }else{
                // no recognized type
            }
        }
    }
    
    // }
    
}




@end
