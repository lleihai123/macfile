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
#define  CHUNK_SIZE 128
@implementation ViewController

- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSInteger valueSize = 0;
    muArray = [NSMutableArray array];
    NSString *path = @"/Users/apple/Movies";
    [self testPath:path];
    NSTimeInterval begin =  [[NSDate date]timeIntervalSince1970];
    NSMutableDictionary*mudict = [NSMutableDictionary dictionary];
    NSString*key = nil;
    for (NSString*pa in muArray) {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
        key = [self fileMD5:pa];
        if (key) {
            if (![mudict objectForKey:key]) {
                [mudict setObject:pa forKey:key];
            }else{
                valueSize += [self fileSizeAtPath:pa];
                NSLog(@"key=%@    (%@)==(%@)",key,[mudict objectForKey:key],pa);
            }
        }else{
            NSLog(@"md5失败:%@",pa);
        }
        [pool release];
        pool = nil;
    }
    NSTimeInterval diff =  [[NSDate date]timeIntervalSince1970] - begin;
    if (muArray && mudict) {
        NSString*outMsg = [NSString stringWithFormat:@"搜索文件数:(%lu)  文件相同数:(%lu)  执行事件:(%f)  合并可节约（%ldM）",(unsigned long)muArray.count,(muArray.count-[mudict allKeys].count),diff,valueSize/(1024*1024)];
        NSLog(@"%@",outMsg);
    }
    
}



-(NSString*)fileMD5:(NSString*)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) {
        NSLog(@"ERROR GETTING FILE MD5");
        return nil; // file didnt exist
    }
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    NSData* fileData = nil;
    BOOL done = NO;
    while(!done)
    {
        fileData = [handle readDataOfLength: CHUNK_SIZE ];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
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
