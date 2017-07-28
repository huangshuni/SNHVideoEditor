//
//  NSString+TimeConvert.m
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/27.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "NSString+TimeConvert.h"

@implementation NSString (TimeConvert)

+(NSString *)getCurrentTime
{
    // 获得当前时间
    NSDate*date = [NSDate date];
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    
    comps =[calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                 NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                       fromDate:date];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    
    NSString *currentTIme = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)year,month,day,hour,minute,second];
    return currentTIme;
}


@end
