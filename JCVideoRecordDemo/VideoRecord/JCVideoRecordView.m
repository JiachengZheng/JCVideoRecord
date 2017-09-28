//
//  JCVideoRecordView.m
//  Pods
//
//  Created by zhengjiacheng on 2017/8/31.
//
//

#import "JCVideoRecordView.h"
#import "JCVideoRecordManager.h"
#import "JCRecordPlayerView.h"
#import "JCVideoRecordProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface JCVideoRecordView()<JCVideoRecordManagerDelegate>
@property (nonatomic, strong)JCVideoRecordManager *recorderManager;
@property (nonatomic, strong) UIView *recordBtn;
@property (nonatomic, strong) UIView *recordBackView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) JCVideoRecordProgressView *progressView;
@property (nonatomic, weak) UIWindow *originKeyWindow;
@property (nonatomic, strong) NSURL *recordVideoUrl;
@property (nonatomic, strong) NSURL *recordVideoOutPutUrl;
@property (nonatomic, assign) BOOL videoCompressComplete;
@end

@implementation JCVideoRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        frame.origin.y = frame.size.height;
        self.frame = frame;
        self.windowLevel = UIWindowLevelStatusBar + 1;
        [self initSubViews];
        self.originKeyWindow = [[UIApplication sharedApplication].delegate window];
        [self makeKeyAndVisible];
    }
    return self;
}

#pragma mark - 视图
- (void)initSubViews{
    _contentView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_contentView];
    _recorderManager = [[JCVideoRecordManager alloc]init];
    _recorderManager.delegate = self;
    [_contentView.layer addSublayer:self.recorderManager.preViewLayer];
    _recorderManager.preViewLayer.frame = self.bounds;
    [_contentView addSubview:self.recordBackView];
    [_contentView addSubview:self.backButton];
    [_contentView addSubview:self.tipLabel];
    [_contentView addSubview:self.switchCameraButton];
    [_contentView addSubview:self.progressView];
    [_contentView addSubview:self.recordBtn];
    [_contentView addSubview:self.focusImageView];
    [_contentView bringSubviewToFront:_recordBtn];
    [self addFocusGensture];
}

#pragma mark - 点按时聚焦

- (void)addFocusGensture{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [_contentView addGestureRecognizer:tapGesture];
}

- (void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.contentView];
    [self setFocusCursorWithPoint:point];
    [self.recorderManager setFoucusWithPoint:point];
}

-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusImageView.center = point;
    self.focusImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:0.2 animations:^{
        self.focusImageView.alpha = 1;
        self.focusImageView.transform = CGAffineTransformMakeScale(1, 1);
    }completion:^(BOOL finished) {
        [self performSelector:@selector(autoHideFocusImageView) withObject:nil afterDelay:1];
    }];
}

- (void)autoHideFocusImageView{
    self.focusImageView.alpha = 0;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _recorderManager.preViewLayer.frame = self.bounds;
}

- (UIImageView *)focusImageView{
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"record_video_focus"]];
        _focusImageView.alpha = 0;
        _focusImageView.frame = CGRectMake(0, 0, 75, 75);
    }
    return _focusImageView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"record_video_back"] forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(60, self.recordBtn.centerY - 18, 36, 36);
        [_backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (JCVideoRecordProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[JCVideoRecordProgressView alloc] initWithFrame:self.recordBackView.frame];
    }
    return _progressView;
}

- (UIButton *)switchCameraButton{
    if (!_switchCameraButton) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraButton setImage:[UIImage imageNamed:@"record_video_camera"] forState:UIControlStateNormal];
        _switchCameraButton.frame = CGRectMake(self.width - 20 - 28, 20, 30, 28);
        [_switchCameraButton addTarget:self action:@selector(clickSwitchCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

- (UIView *)recordBackView{
    if (!_recordBackView) {
        CGRect rect = self.recordBtn.frame;
        CGFloat gap = 7.5;
        rect.size = CGSizeMake(rect.size.width + gap*2, rect.size.height + gap*2);
        rect.origin = CGPointMake(rect.origin.x - gap, rect.origin.y - gap);
        _recordBackView = [[UIView alloc]initWithFrame:rect];
        _recordBackView.backgroundColor = [UIColor whiteColor];
        _recordBackView.alpha = 0.6;
        [_recordBackView.layer setCornerRadius:_recordBackView.frame.size.width/2];
    }
    return _recordBackView;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.width - 50)/2, self.recordBackView.origin.y - 30, 100, 20)];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.text = @"长按拍摄";
        _tipLabel.font = [UIFont systemFontOfSize:12];
    }
    return _tipLabel;
}

-(UIView *)recordBtn{
    if (!_recordBtn) {
        _recordBtn = [[UIView alloc]init];
        CGFloat deta = [UIScreen mainScreen].bounds.size.width/375;
        CGFloat width = 60.0*deta;
        _recordBtn.frame = CGRectMake((self.width - width)/2, self.height - 107*deta, width, width);
        [_recordBtn.layer setCornerRadius:_recordBtn.frame.size.width/2];
        _recordBtn.backgroundColor = [UIColor whiteColor];
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(startRecord:)];
        [_recordBtn addGestureRecognizer:press];
        _recordBtn.userInteractionEnabled = YES;
    }
    return _recordBtn;
}

#pragma mark - 点击事件
- (void)clickSwitchCamera{
    [self.recorderManager switchCamera];
}

- (void)clickBackButton{
    [self dismiss:YES];
}

#pragma mark - 开始录制
- (void)startRecord:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.recordVideoUrl = nil;
        self.videoCompressComplete = NO;
        self.recordVideoOutPutUrl = nil;
        [self startRecordAnimate];
        CGRect rect = self.progressView.frame;
        rect.size = CGSizeMake(self.recordBackView.size.width - 3, self.recordBackView.size.height - 3);
        rect.origin = CGPointMake(self.recordBackView.origin.x + 1.5, self.recordBackView.origin.y + 1.5);
        self.progressView.frame = self.recordBackView.frame;
        self.backButton.hidden = YES;
        self.tipLabel.hidden = YES;
        self.switchCameraButton.hidden = YES;
        NSURL *url = [NSURL fileURLWithPath:[JCVideoRecordManager cacheFilePath:YES]];
        [self.recorderManager startRecordToFile:url];
    }else if(gesture.state >= UIGestureRecognizerStateEnded){
        [self stopRecord];
    }else if(gesture.state >= UIGestureRecognizerStateCancelled){
        [self stopRecord];
    }else if(gesture.state >= UIGestureRecognizerStateFailed){
        [self stopRecord];
    }
}

- (void)startRecordAnimate{
    [UIView animateWithDuration:0.2 animations:^{
        self.recordBtn.transform = CGAffineTransformMakeScale(0.66, 0.66);
        self.recordBackView.transform = CGAffineTransformMakeScale(6.5/5, 6.5/5);
    }];
}

#pragma mark - 停止录制
- (void)stopRecord{
    [self.recorderManager stopCurrentVideoRecording];
}

#pragma mark - 弹出视图
- (void)present{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = self.frame;
        rect.origin.y = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = rect;
        }];
    });
}

#pragma mark - 收起视图
- (void)dismiss:(BOOL)cancel{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = self.frame;
        rect.origin.y = self.height;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = rect;
        }completion:^(BOOL finished) {
            [self.originKeyWindow makeKeyAndVisible];
            [self removeFromSuperview];
            if (self.cancelBlock && cancel) {
                self.cancelBlock();
            }
        }];
    });
}

#pragma mark - 录制结束循环播放视频
- (void)showVedio:(NSURL *)playUrl{
    JCRecordPlayerView *playView= [[JCRecordPlayerView alloc]initWithFrame:self.bounds];
    playView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:playView];
    playView.playUrl = playUrl;
    __weak typeof(self) instance = self;
    playView.cancelBlock = ^{
        [instance clickCancel];
    };
    playView.confirmBlock = ^{
        if (!instance.videoCompressComplete) {
            return ;
        }
        [instance saveVideo];
        if (instance.completionBlock && instance.recordVideoOutPutUrl) {
            instance.completionBlock(instance.recordVideoOutPutUrl);
        }
        [instance dismiss:NO];
    };
}

- (void)saveVideo{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([self.recordVideoUrl path])) {
        //保存视频到相簿
        UISaveVideoAtPathToSavedPhotosAlbum([self.recordVideoUrl path], self,
                                            @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存视频完成");
}

- (void)compressVideo{
    __weak typeof(self) instance = self;
    [self.recorderManager compressVideo:self.recordVideoUrl complete:^(BOOL success, NSURL *outputUrl) {
        if (success && outputUrl) {
            instance.recordVideoOutPutUrl = outputUrl;
        }
        instance.videoCompressComplete = YES;
    }];
}

#pragma mark - 取消录制的视频
- (void)clickCancel{
    self.recordBtn.transform = CGAffineTransformMakeScale(1, 1);
    self.recordBackView.transform = CGAffineTransformMakeScale(1, 1);
    [self.recorderManager prepareForRecord];
    self.backButton.hidden = NO;
    self.tipLabel.hidden = NO;
    self.switchCameraButton.hidden = NO;
}

#pragma mark - JCVideoRecordManagerDelegate method
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    [self.progressView setProgress:0];
    if (!error) {
        //播放视频
        self.recordVideoUrl = outputFileURL;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showVedio:outputFileURL];
        });
        [self compressVideo];
    }
}

- (void)recordTimeCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime{
    self.progressView.totolProgress = totalTime;
    self.progressView.progress = currentTime;
}

- (void)dealloc{

}







@end
