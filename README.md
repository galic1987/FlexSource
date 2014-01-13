What is FlexSource?
================

FlexSource is web extraction framework for mobile (iOS) applications. One can decouple information extraction method from the Internet via XML rules that mobile application can stream when starting app (or on some other time point/event). 



![Alt text](http://galic-design.com/flexSourceTests/shot.png)



There are 3 main elements that concern developer in FlexSource:

1. **XML Rules** - Contain extraction rules i.e. where and how to get information
2. **HTML/XML Internet Sources** - Containing data to be extracted
3. **Native NSObject Data placeholders** - Used by FlexSource to fill it with data from the internet

Where should I use this framework?
=======================
If you want to build mobile applications that are error resistant and flexible regarding external web sources (third party changes). While desktop applications are less restricted and offer more flexibility for the developer, mobile applications are mostly in highly restricted areas that don’t allow them to update arbitrarily. Second thing is that the review process for updating mobile applications is conducted by humans and can take weeks. 

QuickStart
========
1. Include framework in project
2. Define XML rules
3. Define Native Objective C Data placeholders
4. Access finished data objects... etc...


How to include FlexSource in my project?
=======================

1. Clone this repository and copy whole FlexSource folder to your new project. 
2. Use cocoa pods. Add to your podfile following `pod 'FlexSource'`.

*Hint: You might need to include xmllib2.dylib to Project->Build Phases->Link Binary With Libraries* in xCode if you prefer option nr. 1 .
 
###How to use?###

```objective-c

//put in .h file

#import "FlexSource.h"


FlexSource *fx = [[FlexSource alloc]initWithRuleUrl:@"http://linktomyrule.com/rule.xml"]; 

// will disable NSLog 

fx.log = NO; 

// with this turned on, xml rule will be validated, and it will not continue if it is not xsd valid (you may find schema file in project FlexSource/Supporting Files/ruleSchema.xsd)
// Alternative schema location: http://galic-design.com/flexSourceTests/schema.xml 


fx.strictSchemaValidation = YES;

fx.delegate = self

//will trigger rule download and parsing of them to object pool
// is blocking, do not do this with main thread
[fx updateRules];

//will trigger object pool parsing and download of internet sources

[fx parse];
```


### 1. How to create XML rules for data extraction?###

You need knowledge of xPath Queries and XML. You may consider using tools - FireFox plugins:

1. [FireBug]: <https://getfirebug.com/>  "Used for standard web inspection"
2. [FirePath]: <https://addons.mozilla.org/en-US/firefox/addon/firepath/>  "Used to generate xPath direct in website"

Download this 2 plugins and start generating xPath queries for your XML rules.

Here is one example XML rule:

```xml
<objects parserVersion="1.0" 
fileVersion="1.0"
xmlns="http://galic-design.com"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://galic-design.com/flexSourceTests/schema.xml"
>
    <object type="NSIvoObject" name="resource1" priority="1" >		
        <source priority="2" >
            <url step="1" uri="https://addons.mozilla.org/en-us/firefox/addon/firepath/">
                <fields>
                    <field name="sett" type="NSString">//*[@id='addon']/hgroup/h1/span[1]/text()</field>
                </fields>
            </url>
        </source>
    </object>
</objects>
```

More examples to be found at 
[Example Rule]: <http://galic-design.com/flexSourceTests/rule2.xml> ""


###How to create Data placeholder objective c objects?###
If you look above there is object with **NSIvoObject** type defined `<object type="NSIvoObject"` , and you should create new class with the same name:
And add property **sett** of type **NSString** as defined further in fields. 
`
<field name="sett" type="NSString">
` .

Currently, framework supports only two types: NSString and int (more to come)

### How do I get information that my objects are parsed or failed?###

There is `FlexSourceResponderDelegate` that needs to be implemented i.e. look above at `fx.delegate = self;`. Delegate object must have this implementations:

```objective-c 
// object is finished and parsed

-(void)finishedObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;

// unable to parse the object

-(void)errorOnObjectWithId:(NSString*)resourceID theObject:(NSObject*)object withStatus:(NSString*)status withMessage:(NSString*)message;

// unable to parse the rules for object parsing

-(void)failedParsing:(NSString*)description;

// test delegates

-(void)testResultOnObject:(NSMutableArray *)objects result:(BOOL)result msg:(NSString*)msg;
```

#Testing - How to create data extraction Tests?#

Test rule example

```xml
<objects parserVersion="1.0" 
fileVersion="1.0"
xmlns="http://galic-design.com"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://galic-design.com/flexSourceTests/schema.xml"
>
<object type="Test" name="resource4" priority="2" loading="">
    <source priority="1" >
        <url step="1" uri="https://addons.mozilla.org/en-us/firefox/addon/firepath/">
            <headers>
					<header key="User-Agent">Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:24.0) Gecko/20100101 Firefox/24.0</header>
					<header key="Connection">keep-alive</header>
					<header key="Pragma">no-cache</header>
				</headers>
            <fields>
                <field name="sett" type="NSString" expectedValue="FirePath">//*[@id='addon']/hgroup/h1/span[1]/text()</field> 
                <field name="sett2" type="NSString" expectedValue="firepath">//*[@id='addon']/hgroup/h1/span[1]/text()</field> 
            </fields>
        </url>
    </source>
</object>
</objects>
```

 *Object type [Test] will always be tested and will produce number of tests as fields. It will inform delegate* `-(void)testResultOnObject:(NSMutableArray *)objects result:(BOOL)result msg:(NSString*)msg;`
 *after tests have been conducted. You don't need to create Objective C class with name Test*

Can I parse array of objects?
===
Yes. You can encapsulate objects in different form (array objects). Look for some examples on example file on my website [Example Rule]: <http://galic-design.com/flexSourceTests/rule2.xml> 

```xml
<fields>
                <arrayfield name="ar" type="TestObject" startOffset="1" endOffset="11">
                    <xpath>//*[@id='trade_history']/table/tbody/tr</xpath>
                    <arrayobject>
                        <field name="t1" type="NSString" prefix="" sufix="">td[1]/span/text()</field>
                        <field name="t2" type="NSString">td[3]/text()</field>
                    </arrayobject>
                </arrayfield>
            </fields>
```

What about javascript?
===
You can turn javascript processing on url level by attribute `javascript="1"` (Default is 0). Additionally one could add attribute ` waitJSComputation="3"` where 3 describes number of seconds of inactivity to be waited for javaScript computation. This might be useful if javaScript uses some external network requests to get some additional data needed for that data object. Total timeout time can be set in configuration/SettingsHelper.m , default is 15 seconds. 



##Is FlexSource fast?##
Yes :) . Critical components (Data Parser) are written in C and uses xmllib2 to process HTML xPath queries. Other pats of library use foundation framework. 

###How is parsing conducted?###
One thread per object. You can de/increase total number of threads configuration/SettingsHelper.m.

###I want some objects be sooner parsed then other, how can I achieve that?###

Just add `priority` attribute lower, parsing for them will be started earlier.

##How to execute urls step by step?##

There is attribute `step` in url tag. Lower are first to come.

##License##
 MIT [License]: <http://en.wikipedia.org/wiki/MIT_license> "MIT License"

Please contact me if you made app with help of this framework so I can put it on the list. :)

