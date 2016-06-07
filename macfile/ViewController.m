//
//  ViewController.m
//  macfile
//
//  Created by leihai on 16/6/7.
//  Copyright © 2016年 雷海. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "ViewController.h"
NSMutableArray*muArray=nil;
NSInteger DataLengthLimit = 68750;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    muArray = [NSMutableArray array];
    NSString *path = @"/Users/apple/Movies";
    [self testPath:path];
    NSTimeInterval begin =  [[NSDate date]timeIntervalSince1970];
    NSMutableDictionary*mudict = [NSMutableDictionary dictionary];
    NSData*data=nil;
    NSString*key = nil;
    for (NSString*pa in muArray) {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
        data = [NSData dataWithContentsOfFile:pa];
        if (data) {
            NSString*str = [self getStr:data];
            if (str) {
                key = [self md5:str];
                if (key) {
                    if (![mudict objectForKey:key]) {
                        [mudict setObject:pa forKey:key];
                    }else{
                        NSLog(@"key=%@    (%@)==(%@)",key,[mudict objectForKey:key],pa);
                    }
                }else{
                    NSLog(@"md5失败:%@",pa);
                }

            }else{
                NSLog(@"nsdata->nsstring 失败:%@",pa);
            }
            
        }else{
            NSLog(@"读文件失败:%@",pa);
        }
        [pool release];
        pool = nil;
    }
    NSTimeInterval diff =  [[NSDate date]timeIntervalSince1970] - begin;
    if (muArray && mudict) {
        NSLog(@"搜索文件数:(%lu)  文件相同数:(%lu)  执行事件:(%f) ",(unsigned long)muArray.count,(muArray.count-[mudict allKeys].count),diff);
    }
    
}


-(NSString*)getStr:(NSData*)data{
    if (data.length < DataLengthLimit) {
        NSString*str =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (str) {
            return str;
        }
    }
    NSInteger diffIndex = sqrt(data.length);
    NSString *newHexStr = [NSString stringWithFormat:@"%lu_",(unsigned long)data.length];///16进制数
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr;
    for(int i=0; i < diffIndex;i++){
        hexStr = [NSString stringWithFormat:@"%x",bytes[i*i]];
        newHexStr = [newHexStr stringByAppendingString:hexStr];
        hexStr = nil;
    }
    hexStr = [NSString stringWithFormat:@"%x",bytes[data.length-1]];
    newHexStr = [newHexStr stringByAppendingString:hexStr];
    return newHexStr;
}
#pragma mark MD5加密
-(NSString*)md5:(NSString*)value {
    const char *cStr = [value UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

-(void)testPath:(NSString*)path{
    NSArray *oggFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    if (oggFiles.count) {
        for (NSString*pathForder in oggFiles) {
            NSString*tmppath = [NSString stringWithFormat:@"%@/%@",path,pathForder];
            [self testPath:tmppath];
        }
    }else{
        [muArray addObject:path];
    }
}




@end
