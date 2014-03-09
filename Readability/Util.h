//
//  Util.h
//  Readability
//
//  Created by Helen Weng on 3/8/14.
//  Copyright (c) 2014 JEHM. All rights reserved.
//

#import <Foundation/Foundation.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define YELLOW 0xfff3b3
#define ORANGE 0xed773c
#define BLUE 0x91c1a8
#define RED 0xd6444d
@interface Util : NSObject
+(NSString*)ordinalNum:(NSInteger)num;
+(NSString*)omitHTMLPrefix:(NSString*)url;
@end
