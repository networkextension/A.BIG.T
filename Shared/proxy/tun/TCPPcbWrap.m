//
//  TCPPcbWrap.m
//  Surf
//
//  Created by yarshure on 16/3/17.
//  Copyright © 2016年 yarshure. All rights reserved.
//
//const char * const tcp_state_str[] = {
//    "CLOSED",
//    "LISTEN",
//    "SYN_SENT",
//    "SYN_RCVD",
//    "ESTABLISHED",
//    "FIN_WAIT_1",
//    "FIN_WAIT_2",
//    "CLOSE_WAIT",
//    "CLOSING",
//    "LAST_ACK",
//    "TIME_WAIT"
//};
//enum tcp_state {
//    CLOSED      = 0,
//    LISTEN      = 1,
//    SYN_SENT    = 2,
//    SYN_RCVD    = 3,
//    ESTABLISHED = 4,
//    FIN_WAIT_1  = 5,
//    FIN_WAIT_2  = 6,
//    CLOSE_WAIT  = 7,
//    CLOSING     = 8,
//    LAST_ACK    = 9,
//    TIME_WAIT   = 10
//};
#import "TCPPcbWrap.h"

@implementation TCPPcbWrap
+ (enum tcp_state) pcbStatus:(SFPcb)pcb{
    return pcb ->state;
}
@end
