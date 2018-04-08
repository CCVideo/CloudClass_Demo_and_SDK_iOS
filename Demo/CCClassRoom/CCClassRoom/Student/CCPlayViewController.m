//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPlayViewController.h"
#import "CustomTextField.h"
#import <BlocksKit+UIKit.h>
#import "LoadingView.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCStreamShowView.h"
#import "GCPrePermissions.h"
#import "CCLoginScanViewController.h"
#import "CCSignView.h"
#import <Photos/Photos.h>
#import "CCPhotoNotPermissionVC.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "CCVoteView.h"
#import "CCVoteResultView.h"
#import "TZImagePickerController.h"
#import "CCLoginViewController.h"
#import "CCPlayViewController+ActiveAndUnActive.h"

#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

#define TeacherNamedDelTime 0

@interface CCPlayViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate, CCStreamerBasicDelegate, UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong)CCStreamShowView     *streamView;

@property(nonatomic,strong)NSString *localStreamID;
@property(nonatomic,strong)CCStream *mixedStream;
@property(nonatomic,strong)CCStream *localStream;
@property(nonatomic,strong)NSString *regionID;
@property(nonatomic,strong)LoadingView          *loadingView;

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *pickerViewData;
@property(nonatomic,assign)BOOL cameraIsBack;
@property(nonatomic,assign)BOOL audioClose;
@property(nonatomic,assign)BOOL videoCLose;
@end

@implementation CCPlayViewController
- (id)initWithStreamers:(CCStreamerBasic *)streamer
{
    if (self = [super init])
    {
        self.stremer = streamer;
        [self initUI];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLandSpace = YES;
    self.cameraPosition = AVCaptureDevicePositionFront;
    [self addObserver_push];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self loginAction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.streamView = [[CCStreamShowView alloc] init];
    [self.streamView configWithMode:@""];
    [self.view addSubview:self.streamView];
    WS(ws)
    [_streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    self.pickerViewData = @[@"开启预览",
                            @"开启直播",
                            @"开始推流",
                            @"停止推流",
                            @"停止直播",
                            @"停止预览",
                            @"退出",
                            @"添加第三方推流地址",
                            @"变更第三方推流地址",
                            @"移除第三方推流地址",
                            @"合屏",
                            @"取消合屏",
                            @"获取链接状态",
                            @"get region",
                            @"set region",
                            @"切换摄像头",
                            @"开启或者关闭麦克风",
                            @"开启或者关闭摄像头"];
    self.tableView = [UITableView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.view).offset(0.f);
        make.left.mas_equalTo(ws.view).offset(0.f);
        make.width.height.mas_equalTo(200.f);
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - pickerview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pickerViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIndertifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIndertifer];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIndertifer];
    }
    cell.textLabel.text = self.pickerViewData[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 0)
    {
        [self startPreView];
    }
    else if (row == 1)
    {
        [self startLive];
    }
    else if (row == 2)
    {
        [self publish];
    }
    else if (row == 3)
    {
        [self unpublish];
    }
    else if (row == 4)
    {
        [self stopLive];
    }
    else if (row == 5)
    {
        [self stopPreView];
    }
    else if (row == 6)
    {
        [self leave];
    }
    else if (row == 7)
    {
        [self addRtmpUrl];
    }
    else if (row == 8)
    {
        [self updateRtmpUrl];
    }
    else if (row == 9)
    {
        [self removeRtmpUrl];
    }
    else if (row == 10)
    {
        [self mix];
    }
    else if (row == 11)
    {
        [self unMix];
    }
    else if (row == 12)
    {
        [self getconnectionStatus];
    }
    else if (row == 13)
    {
        [self getRegion];
    }
    else if (row == 14)
    {
        [self setRegion];
    }
    else if (row == 15)
    {
        [self changeCamera];
    }
    else if (row == 16)
    {
        [self changeAudio];
    }
    else if (row == 17)
    {
        [self changeVideo];
    }
}

- (void)changeCamera
{
    self.cameraIsBack = !self.cameraIsBack;
    [self.stremer setCameraType:self.cameraIsBack ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront];
}

- (void)changeAudio
{
    self.audioClose = !self.audioClose;
    if (self.audioClose)
    {
        [self.preView.stream disableAudio];
    }
    else
    {
        [self.preView.stream enableAudio];
    }
}

- (void)changeVideo
{
    self.videoCLose = !self.videoCLose;
    if (self.videoCLose)
    {
        [self.preView.stream disableVideo];
    }
    else
    {
        [self.preView.stream enableVideo];
    }
}

- (void)startPreView
{
    
    __weak typeof(self) weakSelf = self;
    [self.stremer startPreview:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            weakSelf.preView = info;
            [weakSelf.streamView showStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)startLive
{
    __weak typeof(self) weakSelf = self;
    [self.stremer startLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)stopLive
{
    __weak typeof(self) weakSelf = self;
    [self.stremer stopLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)publish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer publish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            weakSelf.localStreamID = weakSelf.stremer.localStreamID;
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)unpublish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)stopPreView
{
    __weak typeof(self) weakSelf = self;
    [self.stremer stopPreview:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [weakSelf.streamView removeStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)leave
{
    __weak typeof(self) weakSelf = self;
    [self.stremer leave:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)updateRtmpUrl
{
    __weak typeof(self) weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"rtmp://push-cc1.csslcloud.net/origin/%@", self.stremer.roomID];
    CCLog(@"%@", url);
    [self.stremer updateExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)addRtmpUrl
{
    __weak typeof(self) weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"rtmp://push-cc1.csslcloud.net/origin/%@", self.stremer.roomID];
    CCLog(@"%@", url);
    [self.stremer addExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)removeRtmpUrl
{
    __weak typeof(self) weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"rtmp://push-cc1.csslcloud.net/origin/%@", self.stremer.roomID];
    CCLog(@"%@", url);
    [self.stremer removeExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)mix
{
    __weak typeof(self) weakSelf = self;
    [self.stremer mix:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)unMix
{
    __weak typeof(self) weakSelf = self;
    [self.stremer unmix:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)getconnectionStatus
{
    __weak typeof(self) weakSelf = self;
    [self.stremer getConnectionStats:self.mixedStream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCConnectionStatus *connectionStatus = (CCConnectionStatus *)info;
            
            CCLog(@"%s__%d__%@", __func__, __LINE__, connectionStatus);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)getRegion
{
    __weak typeof(self) weakSelf = self;
    [self.stremer getRegion:self.localStream mixedStream:self.mixedStream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d__%@", __func__, __LINE__, info);
            self.regionID = info;
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)setRegion
{
    __weak typeof(self) weakSelf = self;
    [self.stremer setRegion:self.localStream region:self.regionID mixedStream:self.mixedStream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

#pragma mark - 流
- (void)onServerDisconnected
{
    CCLog(@"%s__%d", __func__, __LINE__);
    [self.stremer leave:^(BOOL result, NSError *error, id info) {
        
    }];
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.navigationController popViewControllerAnimated:NO];
    });
}

- (void)onStreamAdded:(CCStream*)stream
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流不订阅
        self.localStream = stream;
        return;
    }
    if (stream.type == CCStreamType_Mixed)
    {
        self.mixedStream = stream;
    }
    sleep(1.f);
    [self autoSub:stream];
}

- (void)onStreamRemoved:(CCStream*)stream
{
    CCLog(@"%s__%d", __func__, __LINE__);
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流没有订阅
        return;
    }
//    sleep(1.f);
    [self autoUnSub:stream];
}

- (void)onStreamError:(NSError *)error forStream:(CCStream *)stream
{
    CCLog(@"%s__%d__%@__%@", __func__, __LINE__, error, stream.streamID);
}

- (void)autoSub:(CCStream *)stream
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer subcribeWithStream:stream qualityLevel:0 completion:^(BOOL result, NSError *error, id info) {
        CCLog(@"sub success %s__%d__%@__%@", __func__, __LINE__, stream.streamID, @(result));
        if (result)
        {
            [weakSelf.streamView showStreamView:info];
        }
        else
        {
//            [weakSelf showError:error];
        }
    }];
}

- (void)autoUnSub:(CCStream *)stream
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        CCLog(@"%s__%d__%@__%@", __func__, __LINE__, stream.streamID, @(result));
        if (result)
        {
            [weakSelf.streamView removeStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
            if (error.code == 6003)
            {
                //正在订阅中
                CCLog(@"取消订阅失败，重新取消订阅");
                [weakSelf performSelector:@selector(autoUnSub:) withObject:stream afterDelay:1.f];
            }
        }
    }];
}

#pragma mark - show error
- (void)showError:(NSError *)error
{
    NSString *mes = [NSString stringWithFormat:@"%@\n%@", @(error.code), error.domain];
    [UIAlertView bk_showAlertViewWithTitle:@"" message:mes cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

#pragma mark - login
-(void)loginAction
{
    [self.view endEditing:YES];
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在登录..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    __weak typeof(self) weakSelf = self;
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_HIGH;
    
    NSString *authSessionID = self.info[@"data"][@"sessionid"];
    NSString *user_id = self.info[@"data"][@"userid"];
    self.stremer = [[CCStreamerBasic alloc] init];
    self.stremer.videoMode = CCVideoPortrait;
//    self.stremer.delegate = self;
    [self.stremer addObserver:self];
    [self.stremer joinWithAccountID:self.viewerId sessionID:authSessionID config:config areaCode:nil events:@[@"connect",
                                                                                                              @"disconnect",
                                                                                                              @"reconnecting",
                                                                                                              @"reconnect_failed",
                                                                                                              @"reconnect"] completion:^(BOOL result, NSError *error, id info) {
        [weakSelf.loadingView removeFromSuperview];
        if (result)
        {
            [weakSelf.stremer startPreview:^(BOOL result, NSError *error, id info) {
//                [weakSelf rotateOri1:YES];
                if (result)
                {
                    weakSelf.preView = info;
//                    if (self.isLandSpace)
//                    {
//                        CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
//                        [weakSelf.preView setCameraViewTransform:transform];
//                    }
//                    else
//                    {
//                        [weakSelf.preView setCameraViewTransform:CGAffineTransformIdentity];
//                    }
                    [weakSelf.streamView showStreamView:info];
                    
                    [weakSelf.stremer startLive:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            CCLog(@"%s__%d", __func__, __LINE__);
                            [weakSelf.stremer publish:^(BOOL result, NSError *error, id info) {
                                if (result)
                                {
                                    weakSelf.localStreamID = weakSelf.stremer.localStreamID;
                                    CCLog(@"%s__%d", __func__, __LINE__);
                                }
                                else
                                {
                                    [weakSelf showError:error];
                                }
                            }];
                        }
                        else
                        {
                            [weakSelf showError:error];
                        }
                    }];
                }
                else
                {
                    [weakSelf showError:error];
                }
            }];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:NO];
            NSLog(@"__%s__%d__%@", __func__, __LINE__, error);
        }
    }];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{

}

- (void)popToScanVC
{
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[CCLoginViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

+ (NSString *)stringFromTime:(NSTimeInterval)time
{
    if (time < 0)
    {
        return @"00:00";
    }
    NSInteger seconds = time/1000.f;
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",seconds/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}
@end
