//
//  CUtils.h
//  Betelguese
//
//  Created by Sudhip Nashi on 4/16/21.
//  Copyright © 2021 23 Aaron. All rights reserved.
//

#ifndef CUtils_h
#define CUtils_h

#import <Foundation/Foundation.h>
NSString* currentArchitecture(void);
NSString* moveFileToPath(NSString* whatToMove, NSString* whereToMove);
void makeDirectoryRootOwned(NSString* directory);
#endif /* CUtils_h */
