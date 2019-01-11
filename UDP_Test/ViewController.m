//
//  ViewController.m
//  UDP_Test
//
//  Created by duwei on 2019/1/11.
//  Copyright © 2019年 cdz. All rights reserved.
//
//参考链接https://www.jianshu.com/p/1b129597daa9
#import "ViewController.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
@interface ViewController ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate> {
    GCDAsyncUdpSocket *udpSocket;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    [udpSocket bindToPort:8888 error:&error];
    //启用广播
    [udpSocket enableBroadcast:YES error:&error];
    if (error) {
        NSLog(@"启用广播失败");
    } else {
        NSLog(@"%@",[udpSocket localHost]);
        //开始接收消息
        [udpSocket beginReceiving:&error];
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSLog(@"success");
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到响应 %@ %@",ip,s);
    [sock receiveOnce:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        uint16_t port = 9999;
        [self sendBackToHost:ip port:port withMessage:s];
    });
}

- (void)sendBackToHost:(NSString*)ip port:(uint16_t)port withMessage:(NSString*)s {
    char *str = "hello world";
    NSData *data = [NSData dataWithBytes:str length:strlen(str)];
    [udpSocket sendData:data toHost:ip port:port withTimeout:0.1 tag:200];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
