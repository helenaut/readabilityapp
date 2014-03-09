//
//  Util.m
//  Readability
//
//  Created by Helen Weng on 3/8/14.
//  Copyright (c) 2014 JEHM. All rights reserved.
//

#import "Util.h"

@implementation Util

+(NSString*)ordinalNum:(NSInteger)num{
    NSString *ending;
    int ones = num % 10;
    int tens = floor(num / 10);
    tens = tens % 10;
    if(tens == 1){
        ending = @"th";
    }else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    return [NSString stringWithFormat:@"%ld%@", (long)num, ending];
}

+(NSString*)omitHTMLPrefix:(NSString*)url{
    NSArray *htmlComponents = [url componentsSeparatedByString:@"www."];
    if ([htmlComponents count] > 1) {
        return htmlComponents[1];
    }
    
    htmlComponents = [url componentsSeparatedByString:@"://"];
    if ([htmlComponents count] > 1) {
        return htmlComponents[1];
    }
    
    return url;
}

@end
