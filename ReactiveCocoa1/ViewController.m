//
//  ViewController.m
//  ReactiveCocoa1
//
//  Created by zhifu360 on 2019/9/26.
//  Copyright © 2019 ZZJ. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjC.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, copy)   NSString *inputValue;
@property (nonatomic, strong) RACDisposable *disposable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    [self useRACSignal];
    [self useRACSubject];
    [self useRACTuple];
    [self loopArray];
    [self loopDict];
    [self replaceArrayContent];
    [self quickReplaceArrayContent];
    [self observeTextfieldInputChange];
    [self observeButtonClick];
    [self observeLoginButton];
    [self observeNotification];
    [self replaceDelegate];
    [self replaceKVO];
    [self replaceTimer];
}

- (void)createUI
{
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 40)];
    tf.placeholder = @"请输入内容";
    tf.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:tf];
    _textField = tf;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, CGRectGetMaxY(tf.frame), 200, 40);
    [btn setTitle:@"按钮" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    _button = btn;
    
    UITextField *tf1 = [[UITextField alloc] initWithFrame:CGRectMake(100, CGRectGetMaxY(btn.frame), 200, 40)];
    tf1.placeholder = @"请输入用户名";
    tf1.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:tf1];
    _username = tf1;
    
    UITextField *tf2 = [[UITextField alloc] initWithFrame:CGRectMake(100, CGRectGetMaxY(tf1.frame)+10, 200, 40)];
    tf2.placeholder = @"请输入密码";
    tf2.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:tf2];
    _password = tf2;
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(100, CGRectGetMaxY(tf2.frame), 200, 40);
    [btn1 setTitle:@"登录按钮" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    _loginButton = btn1;
}

//RACSignal信号
- (void)useRACSignal
{
    //创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送信号
        [subscriber sendNext:@"发送信号"];
        return nil;
    }];
    
    //订阅信号
    RACDisposable *disposbale = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"信号内容:%@",x);
    }];
    
    //取消订阅
    [disposbale dispose];
}

//RACSubject信号
- (void)useRACSubject
{
    //创建信号
    RACSubject *subject = [RACSubject subject];
    
    //发送信号
    [subject sendNext:@"发送信号"];
    
    //订阅信号（通常在别的视图控制器中订阅，与代理的用法类似）
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"信号内容：%@",x);
    }];
}

//RACTuple
- (void)useRACTuple
{
    //创建元祖
//    RACTuple *tuple = [RACTuple tupleWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    
    //从别的数组中获取内容
//    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"1",@"2",@"3",@"4",@"5"]];
    
    //利用RAC宏快速封装
    RACTuple *tuple = RACTuplePack(@"1",@"2",@"3",@"4",@"5");
    
    NSLog(@"取元祖内容%@",tuple[0]);
    NSLog(@"第一个元素%@",[tuple first]);
    NSLog(@"最后一个元素%@",[tuple last]);
}

//遍历数组
- (void)loopArray
{
    NSArray *array = @[@"1",@"2",@"3",@"4",@"5"];
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"数组内容%@",x);
    }];
}

//遍历字典
- (void)loopDict
{
    NSDictionary *dict = @{@"key1":@"value1",@"key2":@"value2",@"key3":@"value3"};
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString *key, NSString *value) = x;//x 是一个元祖，这个宏能将key、value拆开
        NSLog(@"字典内容：%@:%@",key,value);
    }];
}

//替换数组内容
- (void)replaceArrayContent
{
    NSArray *array = @[@"1",@"2",@"3",@"4",@"5"];
    NSArray *newArray = [[array.rac_sequence map:^id _Nullable(id  _Nullable value) {
        NSLog(@"数组内容:%@",value);
        return @"0";
    }] array];
}

//快速替换数组内容
- (void)quickReplaceArrayContent
{
    NSArray *array = @[@"1",@"2",@"3",@"4",@"5"];
    NSArray *newArray = [[array.rac_sequence mapReplace:@"0"] array];//将所有内容替换为0
    NSLog(@"数组内容：%@",newArray);
}

//监听Textfield的输入改变
- (void)observeTextfieldInputChange
{
    [[_textField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"输入框内容：%@",x);
        self.inputValue = x;
    }];
}

//监听Button点击事件
- (void)observeButtonClick
{
    [[_button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"%@按钮被点击了",x);//x是按钮对象
    }];
    
    [[_loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"登录");
    }];
}

//登录按钮状态实时监听
- (void)observeLoginButton
{
    //下面表示只有 用户名 和 密码 输入框内容都大于 0 时，登录 按钮才可以点击
    RAC(_loginButton, enabled) = [RACSignal combineLatest:@[_username.rac_textSignal, _password.rac_textSignal] reduce:^id _Nonnull (NSString *username, NSString *password) {
        return @(username.length && password.length);
    }];
}

//监听Notification通知事件
- (void)observeNotification
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@ 键盘显示",x);//x是通知对象
    }];
}

//代替Delegate代理方法
- (void)replaceDelegate
{
    [[self rac_signalForSelector:@selector(textFieldDidBeginEditing:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"%@textField 开始编辑了",x);
    }];
    _textField.delegate = self;
}

//代替KVO监听
- (void)replaceKVO
{
//    [[self rac_valuesForKeyPath:@"inputValue" observer:self] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"属性的改变 %@",x);//x是监听属性的改变结果
//    }];
    
    [RACObserve(self, inputValue) subscribeNext:^(id  _Nullable x) {
        NSLog(@"属性的改变 %@",x);//x是监听属性的改变结果
    }];
}

//代替NSTimer计时器
- (void)replaceTimer
{
    self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"当前时间 %@",x);//x是当前系统的时间
        
        [self->_disposable dispose];//关闭计时器
    }];
}

@end
