//
//  ViewController.m
//  CoreAddressBookVC
//
//  Created by 冯成林 on 15/10/20.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "ViewController.h"
#import "CoreAddressBookVC.h"

@interface ViewController ()<CoreAddressBookVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CoreAddressBookVC *addrBVC = [[CoreAddressBookVC alloc] init];

    addrBVC.delegate = self;
    
    UINavigationController *navVC  = [[UINavigationController alloc] initWithRootViewController:addrBVC];
    
    [self presentViewController:navVC animated:YES completion:nil];
}


-(void)addressBookVCSelectedContact:(JXPersonInfo *)personInfo{
    
    NSLog(@"%@",personInfo.selectedPhoneNO);
    
}




@end
