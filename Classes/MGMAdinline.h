//
//  MGMAdinline.h
//  Adinline
//
//  Created by Mr. Gecko on 2/4/11.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>
#import <Adium/AIPlugin.h>
#import <Adium/AISharedAdium.h>
#import <Adium/AIChat.h>
#import <Adium/AIListObject.h>
#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AICorePluginLoader.h>
#import <Adium/AIContentControllerProtocol.h>
#import <Adium/AIInterfaceControllerProtocol.h>
#import "WebKit Message View/AIWebKitMessageViewController.h"

@interface MGMAdinline : AIPlugin <AIHTMLContentFilter> {
	BOOL allowsStrangers;
}

@end