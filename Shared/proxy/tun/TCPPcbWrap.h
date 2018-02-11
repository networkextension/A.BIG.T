//
//  TCPPcbWrap.h
//  Surf
//
//  Created by yarshure on 16/3/17.
//  Copyright © 2016年 yarshure. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "lwip/tcp.h"
#import "StackHelper.h"
@interface TCPPcbWrap : NSObject

+ (enum tcp_state) pcbStatus:(SFPcb)pcb;
@end
//pcb->state