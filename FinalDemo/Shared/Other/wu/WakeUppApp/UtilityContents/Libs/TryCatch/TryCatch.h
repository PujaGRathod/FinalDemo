//
//  TryCatch.h
//  WakeUppApp
//
//  Created by Admin on 23/06/18.
//  Copyright © 2018 el. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TryCatch : NSObject
+(void)try:(void (^)(void))try catch:(void (^)(NSException *))catch finally:(void (^)(void))finally;
@end
