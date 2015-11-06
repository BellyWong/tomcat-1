//
//  ViewController.h
//  TomCat
//
//  Created by dengwei on 15/7/18.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
//汤姆猫图像视图
@property (weak, nonatomic) IBOutlet UIImageView *tomcatImageView;
//动画操作
- (IBAction)animationAction:(UIButton *)sender;

@end

