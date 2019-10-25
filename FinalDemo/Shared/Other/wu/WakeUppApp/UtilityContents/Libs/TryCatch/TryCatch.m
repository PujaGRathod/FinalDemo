//
//  TryCatch.m
//  WakeUppApp
//
//  Created by Admin on 23/06/18.
//  Copyright © 2018 el. All rights reserved.
//

#import "TryCatch.h"

@implementation TryCatch

+(void)try:(void (^)(void))try catch:(void (^)(NSException *))catch finally:(void (^)(void))finally{
    @try {
        try ? try() : nil;
    }
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}

@end
