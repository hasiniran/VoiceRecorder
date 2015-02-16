//
//  DevelopmentSettings.h
//  VoiceRecorder
//
//  Created by Charles Shinaver on 2/15/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#ifndef VoiceRecorder_DevelopmentSettings_h
#define VoiceRecorder_DevelopmentSettings_h

#import <UIKit/UIKit.h>

@interface DevelopmentSettings : NSObject
    //variables for monitoring the audio input and recording
@property double AUDIOMONITOR_THRESHOLD; //don't record if below this number
@property double MAX_SILENCETIME; //max time allowed between words
@property double MAX_MONITORTIME; //max time to try to record for
@property double MAX_RECORDTIME; //max time to try to record for
@property double MIN_RECORDTIME; //minimum time to have in a recording
@property double silenceTime; //current amount of silence time
@property double dt; // Timer (audioMonitor level) update frequencey

@end


#endif
