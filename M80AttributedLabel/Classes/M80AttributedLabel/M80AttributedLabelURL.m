//
//  M80AttributedLabelURL.m
//  M80AttributedLabel
//
//  Created by amao on 13-8-31.
//  Copyright (c) 2013年 www.xiangwangfeng.com. All rights reserved.
//

#import "M80AttributedLabelURL.h"

static NSString *urlExpression = @"((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((:[0-9]+)?)((?:\\/[\\+~%\\/\\.\\w\\-]*)?\\??(?:[\\-\\+=&;%@\\.\\w]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";
static NSString *phoneNumExpression = @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)";
static NSString *emailExpression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

static M80CustomDetectLinkBlock customDetectBlock = nil;

@implementation M80AttributedLabelURL

+ (M80AttributedLabelURL *)urlWithLinkData: (id)linkData
                                     range: (NSRange)range
                                     color: (UIColor *)color
{
    M80AttributedLabelURL *url  = [[M80AttributedLabelURL alloc]init];
    url.linkData                = linkData;
    url.range                   = range;
    url.color                   = color;
    return url;
    
}

+ (M80AttributedLabelURL *)urlWithLinkData:(id)linkData
                                  linkType:(LinkType)linkType
                                     range:(NSRange)range
                                     color:(UIColor *)color
{
    M80AttributedLabelURL *url  = [[M80AttributedLabelURL alloc]init];
    url.linkType                = linkType;
    url.linkData                = linkData;
    url.range                   = range;
    url.color                   = color;
    return url;
}


+ (NSArray *)detectLinks: (NSString *)plainText
{
    NSArray *patterns = @[urlExpression, phoneNumExpression, emailExpression];
    //提供一个自定义的解析接口给
    if (customDetectBlock)
    {
        return customDetectBlock(plainText);
    }
    else
    {
        NSMutableArray *links = nil;
        if ([plainText length])
        {
            links = [NSMutableArray array];
            for (NSInteger i=patterns.count-1; i >= 0; i--) {
                NSArray *array = [self regexWithPattern:patterns[i] plainText:plainText linkType:i];
                [links addObjectsFromArray:array];
            }
        }
        return links;
    }
}

+ (NSArray *)regexWithPattern:(NSString *)pattern plainText:(NSString *)plainText linkType:(LinkType)linkType
{
    NSMutableArray *links = [NSMutableArray array];
    NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:nil];
    [urlRegex enumerateMatchesInString:plainText
                               options:0
                                 range:NSMakeRange(0, [plainText length])
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                NSRange range = result.range;
                                NSString *text = [plainText substringWithRange:range];
//                                switch (linkType) {
//                                    case LinkType_link:
//                                        text = [@"http://" stringByAppendingString:text];
//                                        break;
//                                    case LinkType_phoneNum:
//                                        text = [@"tel://" stringByAppendingString:text];
//                                        break;
//                                    case LinkType_email:
//                                        text = [@"mailto://" stringByAppendingString:text];
//                                        break;
//                                }
                                M80AttributedLabelURL *link = [M80AttributedLabelURL urlWithLinkData:text
                                                                                            linkType:linkType
                                                                                               range:range
                                                                                               color:nil];
                                [links addObject:link];
                            }];
    return links;
}

+ (void)setCustomDetectMethod:(M80CustomDetectLinkBlock)block
{
    customDetectBlock = [block copy];
}

@end
