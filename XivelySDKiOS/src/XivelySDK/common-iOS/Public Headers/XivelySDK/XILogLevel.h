//
//  XICOLogLevel.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#ifndef common_iOS_XILogLevel_h
#define common_iOS_XILogLevel_h

/** @file */

/**
 * @brief Logging levels.
 * @since Version 1.0
 */
typedef NS_ENUM(NSInteger, XILogLevel) {
    XILogLevelTrace       = 1,
    XILogLevelDebug,
    XILogLevelInfo,
    XILogLevelWarning,
    XILogLevelError,
};

#endif
