//
//  AWSDataManager.h
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 9/29/17.
//  Copyright © 2017 University of Notre Dame. All rights reserved.
//

#ifndef AWSDataManager_h
#define AWSDataManager_h


#endif /* AWSDataManager_h */
@protocol AWSDataManagerDelegate <NSObject>
-(void)setNumberOfFilesRemainingForUpload;   //method from ClassA
- (void)fileUploadFailed:(NSString *)errorText error:(NSError *)error;
- (void)uploadedFile:(NSString *)srcPath;
@end
@interface AWSDataManager : NSObject
@property (assign) id <AWSDataManagerDelegate> delegate;
-(void)upload:(NSString*)filepath objectKey:(NSString*)objectKey contentType:(NSString*)contentType;

-(void)cancelAllrequests;
@end
