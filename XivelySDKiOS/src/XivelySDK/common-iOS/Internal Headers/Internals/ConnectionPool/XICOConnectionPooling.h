//
//  XICOConnectionPooling.h
//  common-iOS
//
//  Created by gszajko on 22/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

@protocol XICOConnectionPoolCancelable
-(void) cancel;
@end

@protocol XICOConnectionPooling <NSObject>
-(id<XICOConnectionPoolCancelable>) requestConnectionWithDelegate: (id<XICOConnectionPoolDelegate>) delegate;
-(id<XICOConnectionPoolCancelable>) requestConnectionWithCleanSession: (BOOL) cleanSession
                                                             delegate: (id<XICOConnectionPoolDelegate>) delegate;
-(id<XICOConnectionPoolCancelable>) requestConnectionWithCleanSession: (BOOL) cleanSession
                                                             lastWill: (XILastWill*) lastWill
                                                             delegate: (id<XICOConnectionPoolDelegate>) delegate;
-(id<XICOConnectionPoolCancelable>) requestConnectionWithCleanSession: (BOOL) cleanSession
                                                             lastWill: (XILastWill*) lastWill
                                                                  jwt: (NSString*)jwt
                                                             delegate: (id<XICOConnectionPoolDelegate>) delegate;
-(void) releaseConnection: (id<XICOConnecting>) connection;
@end