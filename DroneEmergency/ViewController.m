//
//  ViewController.m
//  DroneEmergency
//
//  Created by Rodrigo Ramele on 5/7/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import "GCDAsyncUdpSocket.h"
#import "ViewController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ssid;
@property (atomic) int seq;
@end

@implementation ViewController

- (int)sequence
{
    return _seq++;
}

- (IBAction)checknetwork:(id)sender {
    
    _ssid.text = [ViewController currentWifiSSID];
    
}

- (IBAction)takeoff:(id)sender {
    
    [ViewController send:@"192.168.1.1" withMessage:[NSString stringWithFormat:@"AT*FRIM=%d\r", [self sequence]]];
    
    int seq1 = [self sequence];
    int seq2 = [self sequence];
    int seq3 = [self sequence];
    
    [ViewController send:@"192.168.1.1" withMessage:[NSString stringWithFormat:@"AT*REF%d,290718208\rAT*REF=%d,290718208\rAT*REF=%d,290718208\r", seq1, seq2, seq3]];
}

- (IBAction)land:(id)sender {
    
    int seq1 = [self sequence];
    int seq2 = [self sequence];
    int seq3 = [self sequence];
    
    [ViewController send:@"192.168.1.2" withPort:7778 withMessage:@"{\"status\":\"L\", \"speed\":0,\"balance\":0 }"];
    
    [ViewController send:@"192.168.1.1" withMessage:[NSString stringWithFormat:@"AT*REF%d,290717696\rAT*REF=%d,290717696\rAT*REF=%d,290717696\r", seq1, seq2, seq3]];
    
}
- (IBAction)emergency:(id)sender {
    
    int seq1 = [self sequence];
    int seq2 = [self sequence];
    int seq3 = [self sequence];
    
    [ViewController send:@"192.168.1.2" withPort:7778 withMessage:@"{\"status\":\"L\", \"speed\":0,\"balance\":0 }"];
    
    [ViewController send:@"192.168.1.1" withMessage:[NSString stringWithFormat:@"AT*REF%d,290717696\rAT*REF=%d,290717952\rAT*REF=%d,290717696\r", seq1, seq2, seq3]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _seq = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)send:(NSString*)host withMessage:(NSString*)message
{
    [self send:host withPort:5556 withMessage:message];
}

+ (void)send:(NSString*)host withPort:(int)port withMessage:(NSString *)message
{
    GCDAsyncUdpSocket *udpSocket ; // create this first part as a global variable
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSData* data = [[NSString stringWithString:message] dataUsingEncoding:NSASCIIStringEncoding];
    
                    
    [udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:1];
}

+ (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}

@end
