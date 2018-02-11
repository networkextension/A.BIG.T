//
//  StackHelper.c
//  Surf
//
//  Created by abigt on 15/12/25.
//  Copyright © 2015年 abigt. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "StackHelper.h"
#include "SFUtil.h"
//#include "lwipopts.h"

#include <ConditionalMacros.h>
//#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 || __MAC_OS_X_VERSION_MIN_REQUIRED >= 1060)
//#else
//#end
#if TARGET_OS_IPHONE
//
////#import "PacketTunnel/Mac/PacketTunnel_Mac-Swift.h"
//#import "PacketTunnel-Swift.h"
#import "PacketTunnel_iOS-Swift.h"
//#endif
//#if TARGET_OS_MAC
#else 
#import "PacketTunnel_Mac-Swift.h"
//#import "TunServerUI-Swift.h"
#endif
#import <resolv.h>
#include <dns_sd.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>









//#import <SFSocket/SFSocket.h>


void crashSignalHandler(int signal)
{
    //let c  = FileManager.default.containerURLForSecurityApplicationGroupIdentifier("group.com.abigt.Surf")
    //urlContain = c!.appendingPathComponent("Log")
    //SFVPNSession *s = [sf session];
   
    //NSString *name = @"abc";//  s.idenString;
    NSString *d = @"";
    NSString *fileName = [NSString stringWithFormat:@"Log/%@/crash.log",d];
    NSURL *c = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.abigt.Surf"] URLByAppendingPathComponent:fileName];
    
    const char* fileNameCString = [[c path] cStringUsingEncoding:NSUTF8StringEncoding];
    FILE* crashFile = fopen(fileNameCString, "w");
    int crashLogFileDescriptor = crashFile->_file;
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    backtrace_symbols_fd(callstack, frames, crashLogFileDescriptor);
    char **strs = backtrace_symbols(callstack, frames);
    for (int i = 0; i< frames; i++) {
        NSString *str =[NSString stringWithUTF8String:strs[i]];
        DLog(@"######%@",str);
    }
    exit(signal);
}

void installSignalHandler(NSString *d)
{
    //NSSetUncaughtExceptionHandler(&HandleException);
    // learning 
    //http://www.cocoawithlove.com/2010/05/handling-unhandled-exceptions-and.html
    //http://devmonologue.com/ios/ios/implementing-crash-reporting-for-ios/
//#ifdef DEBUG
    //signal(SIGABRT, crashSignalHandler);
    //signal(SIGSEGV, crashSignalHandler);
    //signal(SIGBUS, crashSignalHandler);
    //signal(SIGKILL, crashSignalHandler);
    signal(SIGSYS, crashSignalHandler);
    //signal(SIGTERM, crashSignalHandler);
    signal(SIGSTOP, crashSignalHandler);
    signal(SIGTSTP, crashSignalHandler);
    signal(SIGXCPU, crashSignalHandler);
    signal(SIGXFSZ, crashSignalHandler);
    //signal(SIGILL, crashSignalHandler);
    //signal(SIGFPE, crashSignalHandler);
    //signal(SIGPIPE, crashSignalHandler);
    signal(SIGTRAP, crashSignalHandler);
    
    signal(SIGABRT, crashSignalHandler);
    signal(SIGILL, crashSignalHandler);
    signal(SIGSEGV, crashSignalHandler);
    signal(SIGFPE, crashSignalHandler);
    signal(SIGBUS, crashSignalHandler);
    signal(SIGPIPE, crashSignalHandler);
    signal(SIGHUP, SIG_IGN);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL,
                                                      SIGHUP, 0, queue);
    if (source) {
        dispatch_source_set_event_handler(source, ^{
            crashSignalHandler(0);
        });
        // Start processing signals
        dispatch_resume(source);
    }
//    signal(SIGABRT, SIG_DFL);
//    signal(SIGSEGV, SIG_DFL);
//    signal(SIGBUS, SIG_DFL);
//#endif
}

void lwipassertlog(const char *fmt, ...)
{
//#ifdef DEBUG
    va_list arg_ptr;
    va_start(arg_ptr, fmt);
    char content[256];
    vsnprintf(content, 256, fmt, arg_ptr);
    va_end(arg_ptr);
    //surfLog(content, , 0);
    //[AxLogger log:[NSString stringWithFormat:@"%s",content] level:AxLoggerLevelInfo category:@"cfunc" file:@__FILE__  line:__LINE__ ud:@{@"test":@"test"} tags:@[@"test"] time:[NSDate date]];
    NSLog(@"%s",content);
//#endif
}


NSString* objectClassString(id obj)
{
    NSString *s =  NSStringFromClass([obj class]);
    NSArray *array = [s componentsSeparatedByString:@"."];
    return array.lastObject;
}

#include <errno.h>
#include <sys/sysctl.h>
NSString *kernelVersion(){

    
    char str[256];
    size_t size = sizeof(str);
    int ret = sysctlbyname("kern.osrelease", str, &size, NULL, 0);
    if (ret == 0) {
        return [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    }
    return @"";
    
}
NSString *hwVersion(){
    
    
    char str[256];
    size_t size = sizeof(str);
    int ret = sysctlbyname("hw.machine", str, &size, NULL, 0);
    if (ret == 0) {
        return [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    }
    return @"";
    
}
uint64_t reportMemoryUsed()
{
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t err = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (err == KERN_SUCCESS){
        uint64_t size = vmInfo.internal + vmInfo.compressed - vmInfo.purgeable_volatile_pmap;
        //NSLog(@"current memory use  %llu",sizt);
        return size;
    }else {
        return 0;
        //NSLog(@"error %d",err);
    }
    //return static_cast<size_t>(-1);
    
}

/*
 sodium
*/


BOOL memoryIssue()
{
    NSInteger major = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
    if (major < 10) {
        return YES;
    }
    return  NO;
}
