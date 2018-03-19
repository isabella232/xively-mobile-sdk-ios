//
//  XICOConnectionState.h
//  common-iOS
//
//  Created by gszajko on 09/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#ifndef common_iOS_XICOConnectionState_h
#define common_iOS_XICOConnectionState_h

typedef NS_ENUM(NSInteger, XICOConnectionState) {
    XICOConnectionStateInit,
    XICOConnectionStateConnecting,
    XICOConnectionStateConnected,
    XICOConnectionStateSuspended,
    XICOConnectionStateReconnecting,
    XICOConnectionStateError,
};

#endif
