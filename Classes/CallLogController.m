//
//  CallLogController.m
//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  File created by Pierre-David Bélanger on 2012-11-20.
//

#import "CallLogController.h"

#import "CallLog.h"
#import "AKSIPURI.h"
#import "AccountController.h"
#import "AppController.h"

@implementation CallLogController

@synthesize callLogArrayController = callLogArrayController_;

- (void)dealloc
{
    [callLogArrayController_ release];
    [super dealloc];
}

- (void)windowDidLoad
{
    if ([[callLogArrayController_ sortDescriptors] count] == 0) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [callLogArrayController_ setSortDescriptors:sortDescriptors];
    }
}

- (IBAction)makeCall:(CallLog *)callLog
{
    if (![callLog account])
        return;
    AccountController *theAccountController = nil;
    for (AccountController *accountController in [[NSApp delegate] accountControllers]) {
        if (![accountController isEnabled])
            continue;
        if (![accountController account])
            continue;
        if (![[accountController account] SIPAddress])
            continue;
        if (![[[accountController account] SIPAddress]
              isEqualToString:[callLog account]])
            continue;
        theAccountController = accountController;
        break;
    }
    if (!theAccountController) {
        for (AccountController *accountController in [[NSApp delegate] accountControllers]) {
            if (![accountController isEnabled])
                continue;
            theAccountController = accountController;
            break;
        }
    }
    if (theAccountController) {
        AKSIPURI *uri = [[[AKSIPURI alloc] initWithString:[callLog remoteURI]] autorelease];
        if ([[uri displayName] length] == 0) {
            if ([[callLog remoteName] length] > 0)
                [uri setDisplayName:[callLog remoteName]];
            else if ([[callLog remotePhone] length] > 0)
                [uri setDisplayName:[callLog remotePhone]];
        }
        [theAccountController makeCallToURI:uri phoneLabel:nil];
    }
}

@end
