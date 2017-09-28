//
//  ViewController.m
//  JCVideoRecordDemo
//
//  Created by zhengjiacheng on 2017/9/28.
//  Copyright © 2017年 zhengjiacheng. All rights reserved.
//

#import "ViewController.h"
#import "JCVideoRecordView.h"
#import "UIView+JCAddition.h"
@interface ViewController ()
@property (nonatomic, strong) JCVideoRecordView *recordView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button];
    [button setTitle:@"录制" forState:UIControlStateNormal];
    button.frame = CGRectMake(self.view.width/2 - 25, self.view.height/2 - 25, 50, 50);
    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [button addTarget:self action:@selector(present) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)present{
    _recordView = [[JCVideoRecordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _recordView.cancelBlock = ^{

    };
    _recordView.completionBlock = ^(NSURL *fileUrl) {
        
    };
    [_recordView present];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
