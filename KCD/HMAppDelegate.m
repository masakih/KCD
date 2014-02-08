//
//  HMAppDelegate.m
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import "HMAppDelegate.h"
#import "CustomHTTPProtocol.h"



#import <JavaScriptCore/JavaScriptCore.h>

@interface HMAppDelegate (hoge) <CustomHTTPProtocolDelegate>

@end

@implementation HMAppDelegate

static FILE* logFileP = NULL;

+ (void)initialize
{
	NSString *fullpath = [NSHomeDirectory() stringByAppendingPathComponent:@"kcd.log"];
	logFileP = fopen([fullpath fileSystemRepresentation], "a");
}

- (void)logLineReturn:(NSString *)format, ...
{
	@synchronized (self) {
		va_list ap;
		va_start(ap, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
		fprintf(logFileP, "%s\n", [str UTF8String]);
		fflush(logFileP);
		va_end(ap);
	}
}
- (void)log:(NSString *)format, ...
{
	@synchronized (self) {
		va_list ap;
		va_start(ap, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
		fprintf(logFileP, "%s", [str UTF8String]);
		fflush(logFileP);
		va_end(ap);
	}
}

- (void)showWebFrame:(WebFrame *)webFrame floor:(NSUInteger)floor
{
	NSUInteger f = floor;
	while(f--) [self log:@"    "];
	[self logLineReturn:@"%@", [webFrame name]];
	[self logLineReturn:@"%@", [[[webFrame dataSource] representation] documentSource]];
	
	for(WebFrame *sub in [webFrame childFrames]) {
		[self showWebFrame:sub floor:floor + 1];
	}
}
- (void)showDOM:(DOMNode *)node floor:(NSUInteger)floor
{
	NSUInteger f = floor;
	while(f--) [self log:@"    "];
	[self logLineReturn:@"%@ -- %d", [node nodeName], [node nodeType]];
	
	DOMNodeList *lists = [node childNodes];
	unsigned length = [lists length];
	for(unsigned i = 0; i < length; i++) {
		[self showDOM:[lists item:i] floor:floor + 1];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (void)awakeFromNib
{
	[self.webView setApplicationNameForUserAgent:@"Version/6.0 Safari/536.25"];
	[self.webView setMainFrameURL:@"http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"];
//	[self.webView setMainFrameURL:@"http://www.google.com/"];
	
	
	[CustomHTTPProtocol setDelegate:self];
}

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)argList
{
	[self logLineReturn:[[NSString alloc] initWithFormat:format arguments:argList]];
}

//
//- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
//{
//	NSURL *url = [request URL];
//	NSArray *pathComponents = [url pathComponents];
//	if([pathComponents containsObject:@"kcsapi"]) {
////		[self logLineReturn:@"\nSending Request\n===>\t%@", url];
////
////		NSData *body = [request HTTPBody];
////		if(body && [body length] != 0) {
////			NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
////			bodyString = [bodyString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////			[self logLineReturn:@"===>\t%@", bodyString];
////		}
//		
//		return [pathComponents count] > 3 ?
//		[NSString stringWithFormat:@"hoge-api-%@-%@", [pathComponents objectAtIndex:2], [pathComponents objectAtIndex:3]] :
//		[NSString stringWithFormat:@"hoge-api-%@", [pathComponents objectAtIndex:2]];
//	}
//	
//	return [NSObject new];
//	
//}
//
//- (NSURLRequest *)webView:(WebView *)sender
//				 resource:(id)identifier
//		  willSendRequest:(NSURLRequest *)request
//		 redirectResponse:(NSURLResponse *)redirectResponse
//		   fromDataSource:(WebDataSource *)dataSource
//{
//	NSURL *url = [request URL];
//	NSString *filename = [url lastPathComponent];
//	
//	if([@"181.swf" isEqualToString:filename]
//	   || [@"182.swf" isEqualToString:filename]
//	   || [@"183.swf" isEqualToString:filename] ) {
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//			NSURLResponse *response = nil;
//			NSError *error = nil;
//			NSData *data =
//			[NSURLConnection sendSynchronousRequest:request
//								  returningResponse:&response
//											  error:&error];
//			if(error) {
//				NSLog(@"Could not download main.swf. Reason: %@", error);
//				return;
//			}
//			if(!data || [data length] == 0) {
//				NSLog(@"Counld not download main.swf. data is zero.");
//			}
//			[data writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:filename]
//				   atomically:YES];
//			NSLog(@"finish download main.swf.");
//			
//		});
//	}
//	
//	return request;
//}
//
//- (void)dumpPropertiesObject:(JSObjectRef)object context:(JSContextRef)context floor:(NSUInteger)floor limit:(NSUInteger)limit
//{
//	if(floor > limit) return;
//	
//	JSPropertyNameArrayRef names = JSObjectCopyPropertyNames(context, object);
//	size_t count = JSPropertyNameArrayGetCount(names);
//	size_t i = 0;
//	for(i = 0; i < count; i++) {
//		@autoreleasepool {
//			JSStringRef name = JSPropertyNameArrayGetNameAtIndex(names, i);
//			JSValueRef value = JSObjectGetProperty(context, object, name, NULL);
//			NSString *nameString = (__bridge NSString *)JSStringCopyCFString(kCFAllocatorDefault, name);
//			if([nameString isEqualToString:@"inherits"]) continue;
//			if([nameString isEqualToString:@"document"]) continue;
//			
//			JSType type = JSValueGetType(context, value);
//			NSUInteger f = floor;
//			while(f--) [self log:@"    "];
//			[self logLineReturn:@"%@ (%d)", nameString, type];
//			if(type == kJSTypeObject) {
//				[self dumpPropertiesObject:value context:context floor:floor + 1 limit:limit];
//			}
//		}
//	}
//}

#if 0
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
	if([identifier isKindOfClass:[NSString class]]) {
#if 1
//		static BOOL isFirst = YES;
//		if(!isFirst) return;
//		isFirst = NO;
		
		JSValueRef error = NULL;
		JSContextRef context = [[dataSource webFrame] globalContext];
		JSObjectRef object = JSContextGetGlobalObject(context);
		
//		[self logLineReturn:@"global object properties"];
//		[self dumpPropertiesObject:object context:context floor:0 limit:5];
		
		JSValueRef gadgets = JSObjectGetProperty(context, object, JSStringCreateWithUTF8CString("gadgets"), &error);
		if(error) {
			NSLog(@"ERROR get property gadgets -> %@", JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)error));
			return;
		}
		
//		[self logLineReturn:@"gadgets properties"];
//		[self dumpPropertiesObject:gadgets context:context floor:0 limit:1];
		
		JSValueRef jsonData = JSObjectGetProperty(context, gadgets, JSStringCreateWithUTF8CString("json"), &error);
		if(error) {
			NSLog(@"ERROR get property json -> %@", (__bridge NSString *)JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)error));
			return;
		}
		[self logLineReturn:@"JSON Data Value type -> %d", JSValueGetType(context, jsonData)];
		[self logLineReturn:@"JSON DATA LENGTH -> %d", JSStringGetLength((JSStringRef)jsonData)];
		
		JSStringRef json = JSValueCreateJSONString(context, jsonData, 8, &error);
		if(error) {
			NSLog(@"ERROR create json -> %@", (__bridge NSString *)JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)error));
			return;
		}
		NSString *jsonString = (__bridge NSString *)(JSStringCopyCFString(kCFAllocatorDefault, json));
		[self logLineReturn:@"JSON -> \n%@", jsonString];
		
		// global JSON
		JSValueRef globalJSONData = JSObjectGetProperty(context, object, JSStringCreateWithUTF8CString("JSON"), &error);
		if(error) {
			NSLog(@"ERROR get property JSON -> %@", (__bridge NSString *)JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)error));
			return;
		}
		[self logLineReturn:@"JSON Data Value type -> %d", JSValueGetType(context, globalJSONData)];
		[self logLineReturn:@"WINDOW JSON DATA LENGTH -> %d", JSStringGetLength((JSStringRef)globalJSONData)];
		JSStringRef globalJSON = JSValueCreateJSONString(context, globalJSONData, 8, &error);
		if(error) {
			NSLog(@"ERROR create json -> %@", (__bridge NSString *)JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)error));
			return;
		}
		NSString *globalJSONString = (__bridge NSString *)(JSStringCopyCFString(kCFAllocatorDefault, globalJSON));
		[self logLineReturn:@"WINDOW JSON -> \n%@", globalJSONString];
		
		// window JSON
		JSObjectRef window = JSObjectGetProperty(context, object, JSStringCreateWithUTF8CString("window"), &error);
		
		JSValueRef windowJSONData = JSObjectGetProperty(context, window, JSStringCreateWithUTF8CString("JSON"), &error);
		if(error) {
			NSLog(@"ERROR get property JSON -> %@", (__bridge NSString *)JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)error));
			return;
		}
		[self logLineReturn:@"JSON Data Value type -> %d", JSValueGetType(context, windowJSONData)];
		[self logLineReturn:@"WINDOW JSON DATA LENGTH -> %d", JSStringGetLength((JSStringRef)windowJSONData)];
		JSStringRef windowJSON = JSValueCreateJSONString(context, windowJSONData, 8, &error);
		if(error) {
			NSLog(@"ERROR create json -> %@", (__bridge NSString *)JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)error));
			return;
		}
		NSString *windowJSONString = (__bridge NSString *)(JSStringCopyCFString(kCFAllocatorDefault, windowJSON));
		[self logLineReturn:@"WINDOW JSON -> \n%@", windowJSONString];
#endif
		
//		[self showWebFrame:[dataSource webFrame] floor:0];
		
//		[self showDOM:[[dataSource webFrame] frameElement] floor:0];
	}
}
#endif

//- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
//{
//	NSData *data = [dataSource data];
//	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//	
//	[self logLineReturn:@"%@\n%@\n\n\n", dataSource.initialRequest.URL, string];
//}

@end
