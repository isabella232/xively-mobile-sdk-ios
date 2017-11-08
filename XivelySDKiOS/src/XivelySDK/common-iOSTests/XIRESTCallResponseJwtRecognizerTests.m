//
//  XIRESTCallResponseJwtRecognizerTests.m
//  common-iOS
//
//  Created by vfabian on 04/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIAccess+XIRESTCallResponseRecognizerDelegate.h"
#import "XIRESTCallResponseJwtRecognizer.h"

@interface XIRESTCallResponseJwtRecognizerTests : XCTestCase

@end

@implementation XIRESTCallResponseJwtRecognizerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIAccessXIRESTCallResponseRecognizerAccessExtension {
    NSString *jwt = @"sdgkjfdsgskfdjlghfsdkljgdsghkljfdshgkfldj";
    XIAccess *access = [XIAccess new];
    [access restCallResponseJwtRecognizer:nil didRecognizeJwt:jwt];
    XCTAssert([jwt isEqualToString:access.jwt], @"Jwt setting failed");
}

- (void)testXIAccessXIRESTCallResponseRecognizerRecognizeUsJwt {
    XIRESTCallResponseJwtRecognizer *recognizer = [[XIRESTCallResponseJwtRecognizer alloc] init];
    //OCMockObject *mockDelegate = [OCMockObject mockForProtocol:@protocol((XIRESTCallResponseJwtRecognizerDelegate)];
    OCMockObject *mockDelegate = [OCMockObject mockForProtocol:@protocol(XIRESTCallResponseJwtRecognizerDelegate)];
    recognizer.delegate = (id<XIRESTCallResponseJwtRecognizerDelegate>)mockDelegate;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://id.xively.us/api/v1/auth/login-user"]
                                                              statusCode:200
                                                             HTTPVersion:@"2.0"
                                                            headerFields: @{
                                                                            @"Access-Control-Allow-Credentials" : @"true",
                                                                            @"Access-Control-Allow-Headers" : @"X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept, Authorization, AccessToken, xively-csrf-token",
                                                                            @"Access-Control-Allow-Methods" : @"GET,PUT,POST,DELETE",
                                                                            @"Cache-Control" : @"no-cache, no-store, must-revalidate",
                                                                            @"Connection" : @"keep-alive",
                                                                            @"Content-Length" : @"729",
                                                                            @"Content-Type" : @"application/json; charset=utf-8",
                                                                            @"Date" : @"Thu, 06 Aug 2015 08:27:33 GMT",
                                                                            @"Etag" : @"W/\"2d9-S4QkL5vVn242IojYaF45fg\"",
                                                                            @"Expires" : @"0",
                                                                            @"Pragma" : @"no-cache",
                                                                            @"Set-Cookie" : @"xively-access-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImExOTdhYzZhLTZjYTQtNDgyMS05YWI3LTVlNzk0NDM3YzVhNCIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0Mzg4NTA4NTMzMjEsInJlbmV3YWxLZXkiOiJ5WmlOdXVNN2txVkJkc3lTRGN2QklBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiZTY3MWNiNGYtNDMxMy00YjEzLWIwMTUtOTc3MzA4M2ZkNWExIn0.VD2BhSBQ7tEiF1RA8VBKYxuvyAcNobqw8ODUxuqzqNf_EIIDFSd_DkJ4vydLzZ9Uku2NKpPILvRXB5KhlZsj9WRmq6N0-_D0yswXzbT0DOCJ8vVmqVenWCZGjH-cgb2cJoeVn7z6__4I-qMKrkm3egxQh6Hb21QMS3LmBayD-Jr2Vq1KS3Y7AKMsDTB0L-P15uhJjo6tEbV-lPDPhaU3wYhB8RX57p_pAQIhUuS9MW0jYqAf8G8-qxI_ewr7TjXlGP1WM467fRuv6PBx2lRyIDQyOGqhalKtw4fLsG1YWaeP4xfZqwAtmOyGrVICcz-ZgJR0n5aqr5uv1DmEPbGA7A; Max-Age=315569259.747; Domain=.dev.xively.us; Path=/; Expires=Tue, 05 Aug 2025 18:35:13 GMT, xively-csrf-token=i9Gkgsp%2FYQfyeOFWDh%2BXsQ%3D%3D; Max-Age=315569259.747; Domain=.dev.xively.us; Path=/; Expires=Tue, 05 Aug 2025 18:35:13 GMT",
                                                                            @"X-Powered-By" : @"Express",
                                                                            @"xively-access-token" : @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImExOTdhYzZhLTZjYTQtNDgyMS05YWI3LTVlNzk0NDM3YzVhNCIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0Mzg4NTA4NTMzMjEsInJlbmV3YWxLZXkiOiJ5WmlOdXVNN2txVkJkc3lTRGN2QklBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiZTY3MWNiNGYtNDMxMy00YjEzLWIwMTUtOTc3MzA4M2ZkNWExIn0.VD2BhSBQ7tEiF1RA8VBKYxuvyAcNobqw8ODUxuqzqNf_EIIDFSd_DkJ4vydLzZ9Uku2NKpPILvRXB5KhlZsj9WRmq6N0-_D0yswXzbT0DOCJ8vVmqVenWCZGjH-cgb2cJoeVn7z6__4I-qMKrkm3egxQh6Hb21QMS3LmBayD-Jr2Vq1KS3Y7AKMsDTB0L-P15uhJjo6tEbV-lPDPhaU3wYhB8RX57p_pAQIhUuS9MW0jYqAf8G8-qxI_ewr7TjXlGP1WM467fRuv6PBx2lRyIDQyOGqhalKtw4fLsG1YWaeP4xfZqwAtmOyGrVICcz-ZgJR0n5aqr5uv1DmEPbGA7A"
                                                                            }];
    
    [[mockDelegate expect] restCallResponseJwtRecognizer:recognizer didRecognizeJwt:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [(NSString *)obj isEqualToString:@"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImExOTdhYzZhLTZjYTQtNDgyMS05YWI3LTVlNzk0NDM3YzVhNCIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0Mzg4NTA4NTMzMjEsInJlbmV3YWxLZXkiOiJ5WmlOdXVNN2txVkJkc3lTRGN2QklBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiZTY3MWNiNGYtNDMxMy00YjEzLWIwMTUtOTc3MzA4M2ZkNWExIn0.VD2BhSBQ7tEiF1RA8VBKYxuvyAcNobqw8ODUxuqzqNf_EIIDFSd_DkJ4vydLzZ9Uku2NKpPILvRXB5KhlZsj9WRmq6N0-_D0yswXzbT0DOCJ8vVmqVenWCZGjH-cgb2cJoeVn7z6__4I-qMKrkm3egxQh6Hb21QMS3LmBayD-Jr2Vq1KS3Y7AKMsDTB0L-P15uhJjo6tEbV-lPDPhaU3wYhB8RX57p_pAQIhUuS9MW0jYqAf8G8-qxI_ewr7TjXlGP1WM467fRuv6PBx2lRyIDQyOGqhalKtw4fLsG1YWaeP4xfZqwAtmOyGrVICcz-ZgJR0n5aqr5uv1DmEPbGA7A"];
    }]];
                                                                         
    [recognizer handleUrlResponse:response];
    [mockDelegate verify];
    
}

- (void)testXIAccessXIRESTCallResponseRecognizerRecognizeComJwt {
    XIRESTCallResponseJwtRecognizer *recognizer = [[XIRESTCallResponseJwtRecognizer alloc] init];
    //OCMockObject *mockDelegate = [OCMockObject mockForProtocol:@protocol((XIRESTCallResponseJwtRecognizerDelegate)];
    OCMockObject *mockDelegate = [OCMockObject mockForProtocol:@protocol(XIRESTCallResponseJwtRecognizerDelegate)];
    recognizer.delegate = (id<XIRESTCallResponseJwtRecognizerDelegate>)mockDelegate;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://id.xively.us/api/v1/auth/login-user"]
                                                              statusCode:200
                                                             HTTPVersion:@"2.0"
                                                            headerFields: @{
                                                                            @"Access-Control-Allow-Credentials" : @"true",
                                                                            @"Access-Control-Allow-Headers" : @"X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept, Authorization, AccessToken, xively-csrf-token",
                                                                            @"Access-Control-Allow-Methods" : @"GET,PUT,POST,DELETE",
                                                                            @"Cache-Control" : @"no-cache, no-store, must-revalidate",
                                                                            @"Connection" : @"keep-alive",
                                                                            @"Content-Length" : @"729",
                                                                            @"Content-Type" : @"application/json; charset=utf-8",
                                                                            @"Date" : @"Thu, 06 Aug 2015 08:27:33 GMT",
                                                                            @"Etag" : @"W/\"2d9-S4QkL5vVn242IojYaF45fg\"",
                                                                            @"Expires" : @"0",
                                                                            @"Pragma" : @"no-cache",
                                                                            @"Set-Cookie" : @"xively-access-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImExOTdhYzZhLTZjYTQtNDgyMS05YWI3LTVlNzk0NDM3YzVhNCIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0Mzg4NTA4NTMzMjEsInJlbmV3YWxLZXkiOiJ5WmlOdXVNN2txVkJkc3lTRGN2QklBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiZTY3MWNiNGYtNDMxMy00YjEzLWIwMTUtOTc3MzA4M2ZkNWExIn0.VD2BhSBQ7tEiF1RA8VBKYxuvyAcNobqw8ODUxuqzqNf_EIIDFSd_DkJ4vydLzZ9Uku2NKpPILvRXB5KhlZsj9WRmq6N0-_D0yswXzbT0DOCJ8vVmqVenWCZGjH-cgb2cJoeVn7z6__4I-qMKrkm3egxQh6Hb21QMS3LmBayD-Jr2Vq1KS3Y7AKMsDTB0L-P15uhJjo6tEbV-lPDPhaU3wYhB8RX57p_pAQIhUuS9MW0jYqAf8G8-qxI_ewr7TjXlGP1WM467fRuv6PBx2lRyIDQyOGqhalKtw4fLsG1YWaeP4xfZqwAtmOyGrVICcz-ZgJR0n5aqr5uv1DmEPbGA7A; Max-Age=315569259.747; Domain=.dev.xively.us; Path=/; Expires=Tue, 05 Aug 2025 18:35:13 GMT, xively-csrf-token=i9Gkgsp%2FYQfyeOFWDh%2BXsQ%3D%3D; Max-Age=315569259.747; Domain=.demo.xively.com; Path=/; Expires=Tue, 05 Aug 2025 18:35:13 GMT",
                                                                            @"X-Powered-By" : @"Express",
                                                                            @"xively-access-token" : @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImExOTdhYzZhLTZjYTQtNDgyMS05YWI3LTVlNzk0NDM3YzVhNCIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0Mzg4NTA4NTMzMjEsInJlbmV3YWxLZXkiOiJ5WmlOdXVNN2txVkJkc3lTRGN2QklBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiZTY3MWNiNGYtNDMxMy00YjEzLWIwMTUtOTc3MzA4M2ZkNWExIn0.VD2BhSBQ7tEiF1RA8VBKYxuvyAcNobqw8ODUxuqzqNf_EIIDFSd_DkJ4vydLzZ9Uku2NKpPILvRXB5KhlZsj9WRmq6N0-_D0yswXzbT0DOCJ8vVmqVenWCZGjH-cgb2cJoeVn7z6__4I-qMKrkm3egxQh6Hb21QMS3LmBayD-Jr2Vq1KS3Y7AKMsDTB0L-P15uhJjo6tEbV-lPDPhaU3wYhB8RX57p_pAQIhUuS9MW0jYqAf8G8-qxI_ewr7TjXlGP1WM467fRuv6PBx2lRyIDQyOGqhalKtw4fLsG1YWaeP4xfZqwAtmOyGrVICcz-ZgJR0n5aqr5uv1DmEPbGA7A"
                                                                            }];
    
    [[mockDelegate expect] restCallResponseJwtRecognizer:recognizer didRecognizeJwt:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [(NSString *)obj isEqualToString:@"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImExOTdhYzZhLTZjYTQtNDgyMS05YWI3LTVlNzk0NDM3YzVhNCIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0Mzg4NTA4NTMzMjEsInJlbmV3YWxLZXkiOiJ5WmlOdXVNN2txVkJkc3lTRGN2QklBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiZTY3MWNiNGYtNDMxMy00YjEzLWIwMTUtOTc3MzA4M2ZkNWExIn0.VD2BhSBQ7tEiF1RA8VBKYxuvyAcNobqw8ODUxuqzqNf_EIIDFSd_DkJ4vydLzZ9Uku2NKpPILvRXB5KhlZsj9WRmq6N0-_D0yswXzbT0DOCJ8vVmqVenWCZGjH-cgb2cJoeVn7z6__4I-qMKrkm3egxQh6Hb21QMS3LmBayD-Jr2Vq1KS3Y7AKMsDTB0L-P15uhJjo6tEbV-lPDPhaU3wYhB8RX57p_pAQIhUuS9MW0jYqAf8G8-qxI_ewr7TjXlGP1WM467fRuv6PBx2lRyIDQyOGqhalKtw4fLsG1YWaeP4xfZqwAtmOyGrVICcz-ZgJR0n5aqr5uv1DmEPbGA7A"];
    }]];
    
    [recognizer handleUrlResponse:response];
    [mockDelegate verify];
    
}


@end
