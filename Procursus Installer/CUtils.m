//
//  CUtils.m
//  Betelguese
//
//  Created by Sudhip Nashi on 4/16/21.
//  Copyright © 2021 23 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <sys/utsname.h>

AuthorizationRef authref;

NSString* currentArchitecture(void) {
    struct utsname sysinfo;
    uname(&sysinfo);
    return [NSString stringWithCString:sysinfo.machine encoding:NSUTF8StringEncoding];
}

NSString* moveFileToPath(NSString* whatToMove, NSString* whereToMove) {
    signal(SIGCHLD, SIG_IGN);
    if (!authref) AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authref);
    
    FILE* ptr;
    
    char* argv[] = {
        "-v",
        [whatToMove UTF8String],
        [whereToMove UTF8String],
        NULL
    };
    
    AuthorizationExecuteWithPrivileges(authref, "/bin/mv", 0, argv, &ptr);
    
    char line[2048];
    int rc = fgets(line, sizeof line , ptr);
    
    NSString* ret = [[NSString alloc] initWithCString:line encoding:NSUTF8StringEncoding];
    
    fclose(ptr);
    
    return ret;
}

void makeDirectoryRootOwned(NSString* directory) {
    signal(SIGCHLD, SIG_IGN);
    if (!authref) AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authref);

    char* argv[] = {
        "-R",
        "root",
        [directory UTF8String],
        NULL
    };
    
    int rc = AuthorizationExecuteWithPrivileges(authref, "/usr/sbin/chown", 0, argv, NULL);
    
    int wt;
    wait(&wt);
    
    return;
}
