//
//  XICOBlueprintUser+AccessBlueprintUserType.m
//  common-iOS
//
//  Created by vfabian on 21/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import "XICOBlueprintUser+AccessBlueprintUserType.h"

@implementation XICOBlueprintUser (AccessBlueprintUserType)

- (XIAccessBlueprintUserType)accessBlueprintUserType {
    switch (self.userType) {
        case XICOBlueprintUserTypeAccountUser:
            return XIAccessBlueprintUserTypeAccountUser;
            
        case XICOBlueprintUserTypeEndUser:
            return XIAccessBlueprintUserTypeEndUser;
            
        default:
            return XIAccessBlueprintUserTypeUndefined;
    }
}

@end
