//
//  HTTPClientTest.h
//  common-iOS
//
//  Created by vfabian on 17/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#ifndef common_iOS_HTTPClientTest_h
#define common_iOS_HTTPClientTest_h

#include <httpclient/httpclient.h>

using namespace xively::common;


class HTTPClientDelegateTest : public IHttpClientDelegate {
protected:
    bool _onHttpClientResponseCalled;
    HttpStatus _onHttpClientResponseStatus;
    std::string _onHttpClientResponseResponse;
    
public:
    HTTPClientDelegateTest() {
        
    }
    
    virtual ~HTTPClientDelegateTest() {
        
    }
    
    virtual void onHttpClientResponse(const HttpStatus& status, const std::string response) const {
        HTTPClientDelegateTest *selfref = const_cast<HTTPClientDelegateTest *>(this);
        selfref->_onHttpClientResponseCalled = true;
        selfref->_onHttpClientResponseStatus = status;
        selfref->_onHttpClientResponseResponse = response;
    }
    
    bool onHttpClientResponseCalled() {
        return _onHttpClientResponseCalled;
    }
    
    xively::common::HttpStatus onHttpClientResponseStatus() {
        return _onHttpClientResponseStatus;
    }
    
    std::string onHttpClientResponseResponse() {
        return _onHttpClientResponseResponse;
    }
};

class HTTPClientTest
: public IHttpClient
, public IHttpClientDelegate {
protected:
    bool _requestCalled;
    HttpMethod _requestMethod;
    std::string _requestUrl;
    
    bool _cancelCalled;

public:
    HTTPClientTest() {
    }
    
    virtual ~HTTPClientTest() {
    }
    
    virtual void request(const HttpMethod& method,
                         const std::string& url,
                         const std::string& contentType,
                         const std::string& authorization,
                         const std::string& body) {
        _requestCalled = true;
    }
    virtual void cancel() {
        _cancelCalled = true;
    }
    
    // IHttpClientDelegate
    virtual void onHttpClientResponse(const HttpStatus& status, const std::string response) const {
        
        if (hasDelegate())
            delegate()->onHttpClientResponse(status, response);
    }
    
    bool requestCalled() {
        return _requestCalled;
    }
    
    HttpMethod requestMethod() {
        return _requestMethod;
    }
    std::string& requestUrl() {
        return _requestUrl;
    }
    
    bool cancelCalled() {
        return _cancelCalled;
    }
};

#endif
