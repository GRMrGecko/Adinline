//
//  MGMAdinline.m
//  Adinline
//
//  Created by Mr. Gecko on 2/4/11.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMAdinline.h"
#import <WebKit/Webkit.h>

NSString * const MGMAIAllowStrangers = @"MGMAIAllowStrangers";

@protocol MGMChatViewController <AIChatViewController>
- (AIWebKitMessageViewController *)messageDisplayController;
@end

@implementation MGMAdinline
+ (id<AIAdium>)adium {
	return adium;
}

- (void)installPlugin {
	allowsStrangers = [[NSUserDefaults standardUserDefaults] boolForKey:MGMAIAllowStrangers];
	[[adium contentController] registerHTMLContentFilter:self direction:AIFilterIncoming];
	[[adium contentController] registerHTMLContentFilter:self direction:AIFilterOutgoing];
}
- (void)uninstallPlugin {
	[[adium contentController] unregisterHTMLContentFilter:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)filterHTMLString:(NSString *)theHTMLString content:(AIContentObject *)theContent {
	AIListObject *source = [theContent source];
	if (allowsStrangers || ![source isStranger]) {
		NSArray *imageExtensions = [NSArray arrayWithObjects:@"png", @"jpg", @"jpeg", @"tif", @"tiff", @"gif", @"bmp", nil];
		NSMutableString *html = [[theHTMLString mutableCopy] autorelease];
		NSRange range = NSMakeRange(0, [html length]);
		NSString *shouldScroll = nil;
		while (range.length>1) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSRange linkRange = [html rangeOfString:@"<a " options:NSCaseInsensitiveSearch range:range];
			if (linkRange.location!=NSNotFound) {
				range.location = linkRange.location+linkRange.length;
				range.length = [html length]-range.location;
				NSRange linkStartRange = [html rangeOfString:@">" options:NSCaseInsensitiveSearch range:range];
				if (linkStartRange.location==NSNotFound)
					continue;
				range.location = linkStartRange.location+linkStartRange.length;
				range.length = [html length]-range.location;
				NSRange linkReplaceEndRange = [html rangeOfString:@"<" options:NSCaseInsensitiveSearch range:range];
				NSRange linkEndRange = [html rangeOfString:@"</a" options:NSCaseInsensitiveSearch range:range];
				if (linkEndRange.location==NSNotFound)
					continue;
				range.location = linkEndRange.location+linkEndRange.length;
				range.length = [html length]-range.location;
				NSMutableString *link = [[html substringWithRange:NSMakeRange(linkStartRange.location+linkStartRange.length, linkEndRange.location-(linkStartRange.location+linkStartRange.length))] mutableCopy];
				NSRange tagRange = NSMakeRange(0, [link length]);
				while (YES) {
					NSRange tagStartRange = [link rangeOfString:@"<" options:NSCaseInsensitiveSearch range:tagRange];
					if (tagStartRange.location==NSNotFound)
						break;
					tagRange.location = tagStartRange.location;
					tagRange.length = [link length]-tagRange.location;
					NSRange tagEndRange = [link rangeOfString:@">" options:NSCaseInsensitiveSearch range:tagRange];
					if (tagEndRange.location==NSNotFound)
						break;
					[link replaceCharactersInRange:NSMakeRange(tagStartRange.location, (tagEndRange.location+tagEndRange.length)-tagStartRange.location) withString:@""];
					tagRange.location = tagStartRange.location;
					tagRange.length = [link length]-tagRange.location;
				}
				if ([imageExtensions containsObject:[[[[NSURL URLWithString:link] path] pathExtension] lowercaseString]]) {
					if (shouldScroll==nil) {
						WebView *webview = (WebView *)[[(id<MGMChatViewController>)[[[theContent chat] chatContainer] chatViewController] messageDisplayController] messageView];
						shouldScroll = [webview stringByEvaluatingJavaScriptFromString:@"nearBottom();"];
					}
					NSString *image = [NSString stringWithFormat:@"<img src=\"%@\" style=\"max-width: 100%%; max-height: 100%%;\" onLoad=\"imageSwap(this, false);alignChat(%@);\" />", link, shouldScroll];
					NSRange replaceRange = NSMakeRange(linkStartRange.location+linkStartRange.length, linkReplaceEndRange.location-(linkStartRange.location+linkStartRange.length));
					[html replaceCharactersInRange:replaceRange withString:image];
					range.location += [image length]-replaceRange.length;
					range.length = [html length]-range.location;
				}
				[link release];
			} else {
				break;
			}
			[pool drain];
		}
		return html;
	}
	return theHTMLString;
}
- (CGFloat)filterPriority {
	return (CGFloat)LOWEST_FILTER_PRIORITY;
}
@end