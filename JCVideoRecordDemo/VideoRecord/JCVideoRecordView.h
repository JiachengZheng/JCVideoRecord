//
//  JCVideoRecordView.h
//  Pods
//
//  Created by zhengjiacheng on 2017/8/31.
//
//

#import <Foundation/Foundation.h>
#import "JCVideoRecordManager.h"
typedef void(^JCVideoRecordViewDismissBlock)(void);
typedef void(^JCVideoRecordViewCompletionBlock)(NSURL *fileUrl);

@interface JCVideoRecordView : UIWindow

@property (nonatomic, copy) JCVideoRecordViewDismissBlock cancelBlock;
@property (nonatomic, copy) JCVideoRecordViewCompletionBlock completionBlock;
- (void)present;

@end
