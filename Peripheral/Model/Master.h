//
//  Master.h
//  Peripheral
//
//  Created by apple on 29/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#define  MasterInstance [Master instance]

#import <Foundation/Foundation.h>

@interface Master : NSObject

+ (Master *)instance;

@property (strong, nonatomic) NSMutableArray *groupNameArray;


@end
