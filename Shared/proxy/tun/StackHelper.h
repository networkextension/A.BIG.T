//
//  StackHelper.h
//  Surf
//
//  Created by abigt on 15/12/25.
//  Copyright © 2015年 abigt. All rights reserved.
//

#ifndef StackHelper_h
#define StackHelper_h
//#import "lwip/tcp.h"
#include <stdio.h>


//#include "init.h"
//#include "timers.h"
#import <signal.h>
//#import "sodium.h"

#import <execinfo.h>
#include <mach/task_info.h>
#include <mach/task.h>
#include <mach/mach_init.h>
//#include <CommonCrypto/CommonCryptor.h>
//#include "udp.h"
//#include "ip_addr.h"
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

//#   define DLog(...)
//#   define SLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


void installSignalHandler(NSString *d);

void crashSignalHandler(int signal);

int int2ip(uint32_t ip,char *p);
void lwiplog(const char *fmt, ...);
NSString* objectClassString(id obj);
#define SLog(fmt, ...) testLog(("%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);;
#define FLog(fmt, ...) testLog( @__FILE__,__LINE__,(" " fmt), ##__VA_ARGS__);
void testLog(NSString *f, int line,char *format,...);
void surfLog(char *string,NSString *file,NSInteger line);

NSString *kernelVersion(void);
NSString *hwVersion(void);
void lwiplog (const char *fmt, ...);
uint64_t reportMemoryUsed(void);

//CCAlgorithm findCCAlgorithm(int index);
BOOL memoryIssue(void);
#endif /* StackHelper_h */
