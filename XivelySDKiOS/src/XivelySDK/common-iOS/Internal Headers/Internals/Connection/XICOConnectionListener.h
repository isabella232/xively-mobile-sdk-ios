//
//  XICOConnectionListener.h
//  common-iOS
//
//  Created by gszajko on 09/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

@protocol XICOConnecting;

@protocol XICOConnectionListener <NSObject>
@optional
-(void) connection: (id<XICOConnecting>) connection willConnectToBroker: (NSURL*) broker;
-(void) connection: (id<XICOConnecting>) connection didConnectedToBroker: (NSURL*) broker;
-(void) connection: (id<XICOConnecting>) connection willReconnectToBroker: (NSURL*) broker;
-(void) connection: (id<XICOConnecting>) connection willSubscribeToTopic: (NSString*) topic;
-(void) connection: (id<XICOConnecting>) connection didSubscribeToTopic: (NSString*) topic qos:(XICOQOS)qos;
-(void) connection: (id<XICOConnecting>) connection didFailToSubscribeToTopic: (NSString*)topic;
-(void) connection: (id<XICOConnecting>) connection willUnsubscribeFromTopic: (NSString*) topic;
-(void) connection: (id<XICOConnecting>) connection didUnsubscribeFromTopic: (NSString*) topic;
-(void) connection: (id<XICOConnecting>) connection didReceivePublishAckFromTopic: (NSString*) topic withData: (NSData*) data messageId: (UInt16) messageId;
-(void) connection: (id<XICOConnecting>) connection didReceiveData: (NSData*) data fromTopic: (NSString*) topic;
-(void) connection: (id<XICOConnecting>) connection didFailToConnect: (NSError*) error;
-(void)connectionWasSuspended:(id<XICOConnecting>)connection;
@end
