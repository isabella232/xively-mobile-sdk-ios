//
//  XICOConnecting.h
//  common-iOS
//
//  Created by gszajko on 09/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

@protocol XICOConnectionListener;

typedef NS_ENUM(NSInteger, XICODisconnectReason) {
    XICODisconnectReasonDisconnect,
    XICODisconnectReasonNetworkError,
    XICODisconnectReasonNotAuthorized,
};

extern UInt16 const XIQoS0MessageId;

@protocol XICOConnecting <NSObject>
@property(nonatomic, readonly) XICOConnectionState state;
@property(nonatomic, readonly) XICODisconnectReason disconnectReason;
-(void) addListener: (id<XICOConnectionListener>) listener;
-(void) addListener: (id<XICOConnectionListener>) listener requestUpdate: (BOOL) requestUpdate;
-(void) removeListener: (id<XICOConnectionListener>) listener;
-(void) subscribeToTopic: (NSString*) topic
                     qos: (XICOQOS) qos;
-(void) unsubscribeFromTopic: (NSString*) topic;
-(NSUInteger) publishData: (NSData*) data
                  toTopic: (NSString*) topic
                  withQos: (XICOQOS) qos
                   retain: (BOOL) retain;
-(void) releaseConnection;
@end
