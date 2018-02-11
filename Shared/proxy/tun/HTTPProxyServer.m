//
//  HTTPProxyServer.c
//  Surf
//
//  Created by 孔祥波 on 16/5/20.
//  Copyright © 2016年 yarshure. All rights reserved.
//

#include "HTTPProxyServer.h"


#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/event.h>
#include <sys/time.h>
#import <Foundation/Foundation.h>
//#import "PacketTunnel-Swift.h"
typedef struct in_addr in_addr;
typedef struct sockaddr_in sockaddr_in;
typedef struct servent servent;
typedef struct timespec timespec;

typedef void (action) (register struct kevent const *const kep);

/* Event Control Block (ecb) */
typedef struct {
    action	*do_read;
    action	*do_write;
    void *client;
    char	*buf;
    unsigned	bufsiz;
} ecb;

static char const *pname;
static struct kevent *ke_vec = NULL;
static unsigned ke_vec_alloc = 0;
static unsigned ke_vec_used = 0;
static char const protoname[] = "tcp";
static char const servname[] = "ndl-aas";

static void
vlog (char const *const fmt, va_list ap)
{
    vfprintf (stderr, fmt, ap);
    fputc ('\n', stderr);
}

static void fatal (char const *const fmt, ...)
__attribute__ ((__noreturn__));

static void
fatal (char const *const fmt, ...)
{
    va_list ap;
    
    va_start (ap, fmt);
    fprintf (stderr, "%s: ", pname);
    vlog (fmt, ap);
    va_end (ap);
    exit (1);
}

static void
error (char const *const fmt, ...)
{
    va_list ap;
    
    va_start (ap, fmt);
    fprintf (stderr, "%s: ", pname);
    vlog (fmt, ap);
    va_end (ap);
}



//static int
//all_digits (register char const *const s)
//{
//    register char const *r;
//    
//    for (r = s; *r; r++)
//        if (!isdigit (*r))
//            return 0;
//    return 1;
//}

static void *
xmalloc (register unsigned long const size)
{
    register void *const result = malloc (size);
    
    if (!result)
         NSLog(@"Memory exhausted");
    return result;
}

static void *
xrealloc (register void *const ptr, register unsigned long const size)
{
    register void *const result = realloc (ptr, size);
    
    if (!result)
        fatal ("Memory exhausted");
    return result;
}

static void
ke_change (register int const ident,
           register int const filter,
           register int const flags,
           register void *const udata)
{
    enum { initial_alloc = 64 };
    register struct kevent *kep;
    
    if (!ke_vec_alloc)
    {
        ke_vec_alloc = initial_alloc;
        ke_vec = (struct kevent *) xmalloc(ke_vec_alloc * sizeof (struct kevent));
    }
    else if (ke_vec_used == ke_vec_alloc)
    {
        ke_vec_alloc <<= 1;
        ke_vec =
        (struct kevent *) xrealloc (ke_vec,
                                    ke_vec_alloc * sizeof (struct kevent));
    }
    
    kep = &ke_vec[ke_vec_used++];
    
    kep->ident = ident;
    kep->filter = filter;
    kep->flags = flags;
    kep->fflags = 0;
    kep->data = 0;
    kep->udata = udata;
}

static void
do_write (register struct kevent const *const kep)
{
    register int n;
    register ecb *const ecbp = (ecb *) kep->udata;
    if (ecbp->client != nil){
        
//        SFHTTPSocketConnection *c = (__bridge_transfer  SFHTTPSConnection*)ecbp->client;
//        if ([c shouldCoseSocket]){
//            error ("Error writing socket: %s", strerror (errno));
//            close ((int)kep->ident);
//            ecbp->client = nil;
//            free (kep->udata);
//            return;
//        }

        //NSData *d = c.socks_recv_bufArray;
        if (0) { //d.length > 0
//            n = write ((size_t)kep->ident, d.bytes, d.length);
//            //free (ecbp->buf);  /* Free this buffer, no matter what.  */
//            // maybe write failure?
//            if (n == -1)
//            {
//                error ("Error writing socket: %s", strerror (errno));
//                close ((int)kep->ident);
//                ecbp->client = nil;
//                free (kep->udata);
//            }else if (n == d.length){
//                NSRange r = NSMakeRange(n, d.length-n);
//                c.socks_recv_bufArray = [NSMutableData dataWithData:[d subdataWithRange:r]];
//                ke_change ((int)kep->ident, EVFILT_WRITE, EV_DISABLE, kep->udata);
//                ke_change ((int)kep->ident, EVFILT_READ, EV_ENABLE, kep->udata);
//            }
        }else {
            
        }
        

        //ecbp->client = (__bridge void*)c;
        //[c ]
    }else {
        
        error ("Error writing socket: %s", strerror (errno));
        close ((int)kep->ident);
        
        free (kep->udata);
    }

    
    
}

static void
do_read (register struct kevent const *const kep)
{
    enum { bufsize = 1024 };
    auto char buf[bufsize];
    register int n;
    register ecb *const ecbp = (ecb *) kep->udata;
    if (ecbp->client != nil){
        if ((n = read (kep->ident, buf, bufsize)) == -1)
        {
            error ("Error reading socket: %s", strerror (errno));
            close ((int)kep->ident);
            ecbp->client = nil;
            free (kep->udata);
        }else if (n == 0)
        {
            error ("EOF reading socket");
            
            close ((int)kep->ident);
            ecbp->client = nil;
            free (kep->udata);
        }else {
//            ecbp->buf = (char *) xmalloc (1);
//            free(ecbp->buf);
//            NSData  * d = [NSData dataWithBytesNoCopy:buf length:n];
//            SFHTTPSocketConnection *c = (__bridge_transfer SFHTTPSocketConnection*)ecbp->client;
//            [c incomingData:d len:d.length];
        }
        
       
        //ecbp->client = (__bridge void*)c;
        //[c ]
    }else {
        error ("client dead ");
        close ((int)kep->ident);
        free (kep->udata);
    }
 
    

    //ecbp->bufsiz = n;
    //memcpy (ecbp->buf, buf, n);
    
    
    ke_change ((int)kep->ident, EVFILT_READ, EV_DISABLE, kep->udata);
    ke_change ((int)kep->ident, EVFILT_WRITE, EV_ENABLE, kep->udata);
}

static void
do_accept (register struct kevent const *const kep)
{
    _exit(0);
//    auto sockaddr_in sin;
//    auto socklen_t sinsiz;
//    register int s;
//    register ecb *ecbp;
//    
//    if ((s = accept ((int)kep->ident, (struct sockaddr *)&sin, &sinsiz)) == -1)
//        fatal ("Error in accept(): %s", strerror (errno));
//    
//    ecbp = (ecb *) xmalloc (sizeof (ecb));
//    if (ecbp->client == nil){
//        SFHTTPSocketConnection *c = [[SFHTTPSocketConnection alloc] init];
//        //ecbp->client = (__bridge void*)c;
//        [[SFTCPConnectionManager shared] addSocketConnection:c];
//        ecbp->client = (__bridge_retained void*)c;
//    }
//    ecbp->do_read = do_read;
//    ecbp->do_write = do_write;
//    ecbp->buf = NULL;
//    ecbp->bufsiz = 0;
//    
//    ke_change (s, EVFILT_READ, EV_ADD | EV_ENABLE, ecbp);
//    ke_change (s, EVFILT_WRITE, EV_ADD | EV_DISABLE, ecbp);
}

static void event_loop (register int const kq)
__attribute__ ((__noreturn__));

static void
event_loop (register int const kq)
{
    for (;;)
    {
        register int n;
        register struct kevent const *kep;
        
        n = kevent (kq, ke_vec, ke_vec_used, ke_vec, ke_vec_alloc, NULL);
        ke_vec_used = 0;  /* Already processed all changes.  */
        
        if (n == -1)
            fatal ("Error in kevent(): %s", strerror (errno));
        if (n == 0)
            fatal ("No events received!");
        
        for (kep = ke_vec; kep < &ke_vec[n]; kep++)
        {
            register ecb const *const ecbp = (ecb *) kep->udata;
            
            if (kep->filter == EVFILT_READ)
                (*ecbp->do_read) (kep);
            else
                (*ecbp->do_write) (kep);
        }
    }
}
void stopserver()
{
    
}
int startserver(int any)
{
    auto in_addr listen_addr;
  
    auto int one = 1;
    register int portno = 0;
   
    register int server_sock;
    auto sockaddr_in sin;
    register servent *servp;
    auto ecb listen_ecb;
    register int kq;
    
    if (any==0) {
         listen_addr.s_addr = htonl (INADDR_LOOPBACK);  /* Default.  */
    }else {
        listen_addr.s_addr = htonl (INADDR_ANY);  /* Default.  */
    }
   
    
    if (portno == 0)
    {
        if ((servp = getservbyname (servname, protoname)) == NULL)
            fatal ("Error getting port number for service `%s': %s",
                   servname, strerror (errno));
        portno = ntohs (servp->s_port);
    }
    
    if ((server_sock = socket (PF_INET, SOCK_STREAM, 0)) == -1)
        fatal ("Error creating socket: %s", strerror (errno));
    
    if (setsockopt(server_sock, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one) == -1)
        fatal ("Error setting SO_REUSEADDR for socket: %s", strerror (errno));
    
    memset (&sin, 0, sizeof sin);
    sin.sin_family = AF_INET;
    sin.sin_addr = listen_addr;
    sin.sin_port = htons (portno);
    
    if (bind (server_sock, (const struct sockaddr *)&sin, sizeof sin) == -1)
        fatal ("Error binding socket: %s", strerror (errno));
    
    if (listen (server_sock, 15) == -1)
        fatal ("Error listening to socket: %s", strerror (errno));
    
    if ((kq = kqueue ()) == -1)
        fatal ("Error creating kqueue: %s", strerror (errno));
    
    listen_ecb.do_read = do_accept;
    listen_ecb.do_write = NULL;
    listen_ecb.buf = NULL;
    listen_ecb.bufsiz = 0;
    
    ke_change (server_sock, EVFILT_READ, EV_ADD | EV_ENABLE, &listen_ecb);
    
    event_loop (kq);
}
