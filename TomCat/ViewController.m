//
//  ViewController.m
//  TomCat
//
//  Created by dengwei on 15/7/18.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

typedef enum
{
    kTomCatFart = 0, //放屁
    kTomCatCymbal, //打镲
    kTomCatDrink, //喝牛奶
    kTomCatEat, //吃鸟
    kTomCatPie, //拍饼
    kTomCatScratch, //抓玻璃
    kTomCatKnockout, //打脸
    kTomCatStomach, //肚皮
    kTomCatFootRight, //右脚
    kTomCatFootLeft, //左脚
    kTomCatAngryTail  //尾巴
    
}kTomCatAnimationType;

@interface ViewController ()
{
    //汤姆猫数据字典
    NSMutableDictionary *_tomcatDict;
    
    //音效的数据字典
    NSMutableDictionary *_soundDict;
}

@end

@implementation ViewController

/**
 *  用数据字典来实现音效管理
 */

-(SystemSoundID)loadSoundId:(NSString *)soundFile
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:soundFile ofType:nil]];
    
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundId);
    
    return soundId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //数据初始化工作，加载数据字典成员变量
    //1.需要指定路径
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Tomcat" ofType:@"plist"];
    
    //2.加载数据字典
    _tomcatDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    //NSLog(@"%@", _tomcatDict);
    
    //3.初始化音效数据字典
    _soundDict = [NSMutableDictionary dictionary];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (IBAction)animationAction:(UIButton *)sender {
    
    //如果汤姆猫在动画中，不允许中断动画
    if ([_tomcatImageView isAnimating]) {
        return;
    }
    
    //1.判断按钮的tag，根据不同的tag加载不同的序列帧图像数组
    //2.设置汤姆猫的图像，开始动画
    //要让代码可读性更好，可以考虑枚举来代替tag
    //引入数据字典会简化操作
    
    NSDictionary *dict = nil;
    
    switch (sender.tag) {
        case kTomCatFart:
            dict = _tomcatDict[@"fart"];
            break;
            
        case kTomCatCymbal:
            dict = _tomcatDict[@"cymbal"];
            break;
            
        case kTomCatDrink:
            dict = _tomcatDict[@"drink"];
            break;
            
        case kTomCatEat:
            dict = _tomcatDict[@"eat"];
            break;
            
        case kTomCatPie:
            dict = _tomcatDict[@"pie"];
            break;
            
        case kTomCatScratch:
            dict = _tomcatDict[@"scratch"];
            break;
            
        case kTomCatKnockout:
            dict = _tomcatDict[@"knockout"];
            break;
            
        case kTomCatStomach:
            dict = _tomcatDict[@"stomach"];
            break;
            
        case kTomCatFootRight:
            dict = _tomcatDict[@"foot-right"];
            break;
            
        case kTomCatFootLeft:
            dict = _tomcatDict[@"foot-left"];
            break;
            
        case kTomCatAngryTail:
            dict = _tomcatDict[@"angry-tail"];
            break;
            
        default:
            break;
    }
    
    //根据选中的字典，初始化序列帧图像
    NSMutableArray *imageList = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [dict[@"frames"]integerValue]; i++) {
        NSString *imageFile = [NSString stringWithFormat:dict[@"imageFormat"], i];
        //imageNamed带有缓存，通过它创建的图片会放到缓存中
        //UIImage *image = [UIImage imageNamed:imageFile];
        //imageWithContentsOfFile这种方式不带缓存，不会使内存占用率飙升
        NSString *path = [[NSBundle mainBundle] pathForResource:imageFile ofType:nil];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        [imageList addObject:image];
        
    }
    
    //------音频处理---------
    //1）从汤姆猫的数据字典中，首先取出声音文件的数组
    NSArray *array = dict[@"soundFiles"];
    //2）判断数组中是否有数据，如果有数据做进一步处理
    SystemSoundID soundId = 0;
    if (array.count > 0) {
        //3）根据数组中的文件名，判断音频字典中是否有对应的记录，如果没有，建立新的音频字典
        for (NSString *fileName in array) {
            SystemSoundID playSoundId = [_soundDict[fileName]unsignedIntValue];
            
            //如果在字典中没有定义音频代号，初始化音频Id，并加入字典
            if (playSoundId <= 0) {
                playSoundId = [self loadSoundId:fileName];
                
                //将playSound加入到数据字典，向字典中增加数据，不是用add
                //向NSDictionary NSArray中添加数值需要“包装”
                //@（）会把一个NSInteger的数字，变成NSNumber的对象
                [_soundDict setValue:@(playSoundId) forKey:fileName];
            }
            
        }
        
        //每一个动画声音可以是多个，为了保证游戏的可玩度，可以采用随机数的方式播放音效
        NSInteger seed = arc4random_uniform((unsigned int)array.count);
        NSString *fileSound = array[seed];
        soundId = [_soundDict[fileSound]unsignedIntValue];
        
    }
    
    //------动画--------
    [_tomcatImageView setAnimationImages:imageList];
    [_tomcatImageView setAnimationDuration:[dict[@"frames"]integerValue]/10.0];
    [_tomcatImageView setAnimationRepeatCount:1];
    [_tomcatImageView startAnimating];
    
    //播放声音
    if (soundId > 0) {
        AudioServicesPlaySystemSound(soundId);
    }
    
    //清空animationImages图片的时间为执行完动画后0.1s
    CGFloat delay = _tomcatImageView.animationDuration + 0.1;
    //延迟执行，清楚动画图片缓存
    [self performSelector:@selector(clearImages) withObject:nil afterDelay:delay];
    
}

-(void)clearImages
{
    //清空animationImages中的图片
    _tomcatImageView.animationImages = nil;
}

@end
