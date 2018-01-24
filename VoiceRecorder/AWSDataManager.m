//
//  AWSDataManager.m
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 9/29/17.
//  Copyright © 2017 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import "AWSDataManager.h"

@interface AWSDataManager ()

@property (copy, nonatomic) AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler;
@property (copy, nonatomic) AWSS3TransferUtilityProgressBlock progressBlock;
@property (nonnull, strong) AWSS3TransferUtility *transferUtility;
@end


@implementation AWSDataManager

NSString *const S3BucketName = @"infvoicerecorder";

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];    }
    return self;
}



-(void)upload:(NSString*)filepath objectKey:(NSString*)objectKey contentType:(NSString*)contentType{
    
//    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    
     __weak AWSDataManager *weakSelf = self;
    self.completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [task cancel];
                [weakSelf cancelAllrequests];
                [weakSelf.delegate fileUploadFailed:[NSString stringWithFormat: @"%@ failed to upload.", filepath] error:error];
            } else {
                 [weakSelf.delegate uploadedFile:filepath];
            }
        });
    };
    
    self.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
          
        });
    };

    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if([filemanager fileExistsAtPath:filepath]){

//    NSData *dataToUpload = [NSData dataWithContentsOfFile:filepath];
    
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Do something e.g. Update a progress bar.
            
        });
    };
    
    

    
  [ [self.transferUtility uploadFile:[NSURL fileURLWithPath:filepath]
                        bucket:S3BucketName
                           key:objectKey
                   contentType:contentType
                    expression:expression
              completionHandler:self.completionHandler] continueWithBlock:^id(AWSTask *task) {
      
                    if (task.error) {
                        
                            [weakSelf cancelAllrequests];
                            [weakSelf.delegate fileUploadFailed:@"%@ failed to upload." error:task.error];
      }
                        return nil;
  }];
    }

    }


-(void)cancelAllrequests{
    [[self.transferUtility getUploadTasks] continueWithBlock:^id(AWSTask *task) {
        if([task isMemberOfClass:AWSS3TransferUtilityUploadTask.self]){
            [(AWSS3TransferUtilityUploadTask*)task cancel];
        }
        return nil;
    }];

}

@end

