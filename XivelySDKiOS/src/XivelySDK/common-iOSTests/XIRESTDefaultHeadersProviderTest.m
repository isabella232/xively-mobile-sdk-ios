//
//  XIRESTDefaultHeadersProviderTest.m
//  common-iOS
//
//  Created by vfabian on 21/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import <Internals/RESTCall/XIAccess+XIRESTDefaultHeadersProvider.h>
#import <Internals/RESTCall/XIRESTDefaultHeadersProvider.h>

@interface XIRESTDefaultHeadersProviderTest : XCTestCase

@end

@implementation XIRESTDefaultHeadersProviderTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIAccessXIRESTDefaultHeadersProvider {
    XIAccess *access = [XIAccess new];
    access.accountId = @"sdkgjsdhgklshgkdgdsfkgjh";
    access.mqttPassword = @"sdkghjgfjhgfhgfjsdhgklshgkdgdsfkgjh";
    access.mqttDeviceId = @"sdkghjgfhjgfhgfghjfhgfjsdhgklshgkdgdsfkgjh";
    access.jwt = @"sdkljghsdalkgjhgrkl4jh35k435jh34kl5j324h5lk345jh";
    
    XCTAssert([access.jwt isEqualToString:access.jwtString], @"Invalid jwtString");
}

- (void)testXIRESTDefaultHeadersProviderCreation {
    OCMockObject *mockJwtSource = [OCMockObject mockForProtocol:@protocol(XIRESTDefaultHeadersProviderJwtSource)];
    XIRESTDefaultHeadersProvider *provider = [[XIRESTDefaultHeadersProvider alloc] initWithJwtSource:(id<XIRESTDefaultHeadersProviderJwtSource>)mockJwtSource];
    XCTAssert(provider, @"Creation failed");
}

- (void)testXIRESTDefaultHeadersProviderHeadersWithoutJwt {
    OCMockObject *mockJwtSource = [OCMockObject mockForProtocol:@protocol(XIRESTDefaultHeadersProviderJwtSource)];
    XIRESTDefaultHeadersProvider *provider = [[XIRESTDefaultHeadersProvider alloc] initWithJwtSource:(id<XIRESTDefaultHeadersProviderJwtSource>)mockJwtSource];
    
    [[[mockJwtSource expect] andReturn:nil] jwtString];
    NSDictionary *headers = [provider defaultHeaders];
    [mockJwtSource verify];
    
    XCTAssert([headers[@"Content-Type"] isEqualToString:@"application/json; charset=utf-8"], @"Missing or invalid content type");
    XCTAssertNil(headers[@"Authorization"], @"Invalid authorization header");
}

- (void)testXIRESTDefaultHeadersProviderHeadersWithJwt {
    OCMockObject *mockJwtSource = [OCMockObject mockForProtocol:@protocol(XIRESTDefaultHeadersProviderJwtSource)];
    XIRESTDefaultHeadersProvider *provider = [[XIRESTDefaultHeadersProvider alloc] initWithJwtSource:(id<XIRESTDefaultHeadersProviderJwtSource>)mockJwtSource];
    
    NSString *jwt = @"dslkgjhfdgkljdsghfsdkjlghdfslkjgfhsgklsfdhgfdlkjghdfslkgjhdfalgkjadfhglkj";
    [[[mockJwtSource stub] andReturn:jwt] jwtString];
    NSDictionary *headers = [provider defaultHeaders];
    [mockJwtSource verify];
    NSString *bearerJwt = [NSString stringWithFormat:@"Bearer %@", jwt];
    XCTAssert([headers[@"Content-Type"] isEqualToString:@"application/json; charset=utf-8"], @"Missing or invalid content type");
    XCTAssert([headers[@"Authorization"] isEqualToString:bearerJwt], @"Missing or invalid authorization");
}

@end
