//
//  UpdateApp.m
//  Peripheral
//
//  Created by apple on 11/01/18.
//  Copyright © 2018年 apple. All rights reserved.
//

#define UpdateURL @"http://www.huazhicloud.com/api/index/getAppversion.html"

#import "UpdateApp.h"
#import "AFNetworking.h"

@implementation UpdateApp

- (void)update:(NSString *)appid
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];

    [manager POST:UpdateURL parameters:@{@"appid":appid,@"app_type":@"ios"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [responseObject objectForKey:@"data"]) {
                NSString *version = [dict objectForKey:@"version"];
                NSNumber *is_update = [dict objectForKey:@"is_update"];
                if (version)
                {
                    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    if ([currentVersion floatValue] < [version floatValue])
                    {
                        if (is_update) {
                            if ([is_update intValue] == 0) {
                                APP.verState = 0;
                            } else {
                                APP.verState = 1;
                            }
                        }
                        PostNotification(@"msgAppVersion", nil);
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
@end
