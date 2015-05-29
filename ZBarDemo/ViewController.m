//
//  ViewController.m
//  ZBarDemo
//
//  Created by 叶华英 on 15/5/19.
//  Copyright (c) 2015年 liuhuan. All rights reserved.
//

#import "ViewController.h"
#import "ZBarSDK.h"
#import <AudioToolbox/AudioToolbox.h>

#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)
#define mainColor [UIColor colorWithRed:254.0/255 green:209.0/255 blue:49.0/255 alpha:1]

@interface ViewController ()<ZBarReaderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>
{
    NSString * symData;//扫描数据
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * qCodeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    qCodeBtn.frame = CGRectMake(95*widthRate, (DeviceMaxHeight-170*widthRate)/2, 130*widthRate, 170*widthRate);
    [qCodeBtn setBackgroundImage:[UIImage imageNamed:@"scanQcode.png"] forState:UIControlStateNormal];
    [qCodeBtn addTarget:self action:@selector(scanButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qCodeBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - 点击扫描
- (void)scanButtonEvent
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.showsZBarControls = NO;
    reader.readerDelegate = self;
    
    [self setOverlayPickerView:reader];
    ZBarImageScanner *scanner = reader.scanner;
    
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [self presentViewController:reader animated:YES completion:^{
    }];
    
}

//设置扫描界面
- (void)setOverlayPickerView:(ZBarReaderViewController *)reader

{
    //清除原有控件
    for (UIView *temp in [reader.view subviews]) {
        
        for (UIButton *button in [temp subviews]) {
            
            if ([button isKindOfClass:[UIButton class]]) {
                [button removeFromSuperview];
            }
            
        }
        
        for (UIToolbar *toolbar in [temp subviews]) {
            
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                [toolbar setHidden:YES];
                [toolbar removeFromSuperview];
                
            }
        }
        
    }
    
    //画中间的基准线
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(20*widthRate, 63+20*widthRate, 280*widthRate, 2)];
    line.layer.cornerRadius = 2;
    line.layer.masksToBounds = YES;
    line.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:line];
    
    [self moveDown:line];
    
    //最上部view
    
    CGFloat alpha = 0.5;
    
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DeviceMaxWidth, 64+20*widthRate)];
    upView.alpha = alpha;
    upView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:upView];
    
    UIImageView * topBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DeviceMaxWidth, 64)];
    topBg.userInteractionEnabled = YES;
    topBg.backgroundColor = mainColor;
    [reader.view addSubview:topBg];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DeviceMaxWidth, 44)];
    titleLabel.frame = CGRectMake(0, 20, DeviceMaxWidth, 44);
    titleLabel.text = @"扫描二维码";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [reader.view addSubview:titleLabel];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(2, 20, 60, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissOverlayView:) forControlEvents:UIControlEventTouchUpInside];
    [reader.view addSubview:btn];
    
    UIButton * ablumbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [ablumbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    ablumbtn.frame = CGRectMake(250*widthRate, 20, 70*widthRate, 44);
    [ablumbtn setTitle:@"相册" forState:UIControlStateNormal];
    [ablumbtn addTarget:self action:@selector(alumbBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    [reader.view addSubview:ablumbtn];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+20*widthRate, 20*widthRate, 280*widthRate)];
    leftView.alpha = alpha;
    leftView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:leftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(300*widthRate, 64+20*widthRate, 20*widthRate, 280*widthRate)];
    rightView.alpha = alpha;
    rightView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:rightView];
    
    //底部view
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+300*widthRate, DeviceMaxWidth, DeviceMaxHeight - 300*widthRate-64)];
    downView.alpha = alpha;
    downView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:downView];
    
    //用于说明的label
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame=CGRectMake(15*widthRate, DeviceMaxHeight-90*widthRate, 290*widthRate, 50*widthRate);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"如果对准二维码5秒后仍未扫描成功\n请直接点击左上角返回按钮，继续操作";
    [reader.view addSubview:labIntroudction];
    
}

//打开相册
- (void)alumbBtnEvent
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        if (IOS8){
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未开启访问相册权限，现在去开启！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 4;
            [alert show];
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        mediaUI.mediaTypes = [UIImagePickerController         availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        mediaUI.allowsEditing = YES;
        mediaUI.delegate = self;
        [self presentViewController:mediaUI animated:YES completion:^{
            
        }];
    }];
    
}

- (void)moveDown:(UIView *)view
{
    [UIView animateWithDuration:2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.frame = CGRectMake(20*widthRate, 64+300*widthRate, 280*widthRate, 2);
    } completion:^(BOOL finished) {
        view.frame = CGRectMake(20*widthRate, 63+20*widthRate, 280*widthRate, 2);
        [self moveDown:view];
    }];
}

//取消button方法
- (void)dismissOverlayView:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    
    if (results) {//相机扫描
        //播放扫描二维码的声音
        SystemSoundID soundID;
        NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
        AudioServicesPlaySystemSound(soundID);
        
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
        
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        symData = symbol.data;
        
        NSLog(@"扫描结果 %@",symData);

    }
    else{//本地扫描
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage]?[info objectForKey:UIImagePickerControllerEditedImage]: [info  objectForKey:UIImagePickerControllerOriginalImage];
        [self scanImage:image picker:picker];
    }
}

//扫描本地二维码
- (void)scanImage:(UIImage*)image picker:(UIImagePickerController *)picker{
    

    ZBarImage *zImage = [[ZBarImage alloc] initWithCGImage:image.CGImage];
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [scanner scanImage:zImage];
    ZBarSymbolSet *set = [scanner results];

    BOOL isScanner = NO;
    for (ZBarSymbol *symbol in set) {
        isScanner = YES;
        symData = symbol.data;
        
        // process symbol.data however you please.
    }
    
    if (isScanner) {
        //播放扫描二维码的声音
        SystemSoundID soundID;
        NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
        AudioServicesPlaySystemSound(soundID);
        
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
        
        //扫描完成
        NSLog(@"扫描结果 %@",symData);
        
    }
    else{
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

@end
