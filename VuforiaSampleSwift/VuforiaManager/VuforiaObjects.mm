//
//  VuforiaObjects.m
//  VuforiaSampleSwift
//
//
//  Created by Andrew Mendez on 2017/02/18.
//  Copyright © 2017 Andrew Mendez. All rights reserved.
//

#import "VuforiaObjects.h"
#import <Vuforia/Renderer.h>
#import <Vuforia/Trackable.h>
#import <Vuforia/TrackableResult.h>

@implementation VuforiaFrame {
    Vuforia::Frame _frame;
}

- (instancetype)initWithFrame:(Vuforia::Frame)frame {
    if(self = [super init]) {
        _frame = frame;
    }
    return self;
}

@end

@implementation VuforiaTrackable {
    const Vuforia::Trackable* _trackable;
}

- (instancetype)initWithTrackable:(const Vuforia::Trackable*)trackable {
    if(self = [super init]) {
        _trackable = trackable;
    }
    return self;
}

- (NSInteger)identifier {
    return _trackable->getId();
}

- (NSString*)name {
    return [NSString stringWithCString:_trackable->getName() encoding:NSUTF8StringEncoding];
}

@end

@implementation VuforiaTrackableResult {
    const Vuforia::TrackableResult* _result;
}

- (instancetype)initWithTrackableResult:(const Vuforia::TrackableResult*)result {
    if(self = [super init]) {
        _result = result;
    }
    return self;
}

- (NSTimeInterval)timeStamp {
    return _result->getTimeStamp();
}

- (VuforiaTrackableResultStatus)status {
    switch (_result->getStatus()) {
        case Vuforia::TrackableResult::STATUS::UNKNOWN:
            return VuforiaTrackableResultStatus_Unknown;
        case Vuforia::TrackableResult::STATUS::UNDEFINED:
            return VuforiaTrackableResultStatus_Undefined;
        case Vuforia::TrackableResult::STATUS::DETECTED:
            return VuforiaTrackableResultStatus_Detected;
        case Vuforia::TrackableResult::STATUS::TRACKED:
            return VuforiaTrackableResultStatus_Tracked;
        case Vuforia::TrackableResult::STATUS::EXTENDED_TRACKED:
            return VuforiaTrackableResultStatus_Extended_tracked;
        default:
            return VuforiaTrackableResultStatus_Unknown;
    }
}

- (VuforiaTrackable*)trackable {
    return [[VuforiaTrackable alloc] initWithTrackable:&_result->getTrackable()];
}

@end

@implementation VuforiaState {
    Vuforia::State* _state;
    
    VuforiaFrame* _frame;
}

- (instancetype)initWithState:(Vuforia::State*)state {
    if(self = [super init]) {
        _state = state;
        _frame = [[VuforiaFrame alloc] initWithFrame:_state->getFrame()];
    }
    return self;
}

- (VuforiaFrame *)frame {
    return _frame;
}

- (int)numberOfTrackables {
    return _state->getNumTrackables();
}

- (int)numberOfTrackableResults {
    return _state->getNumTrackableResults();
}

- (VuforiaTrackable*)trackableAtIndex:(int)index {
    return [[VuforiaTrackable alloc] initWithTrackable:_state->getTrackable(index)];
}

- (VuforiaTrackableResult*)trackableResultAtIndex:(int)index {
    return [[VuforiaTrackableResult alloc] initWithTrackableResult:_state->getTrackableResult(index)];
}

@end
