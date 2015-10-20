//
//  HomeViewController.h
//  JXAdressBookDemo
//
//  Created by andy on 8/15/14.
//  Copyright (c) 2014 JianXiang Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXPersonInfo.h"


@protocol CoreAddressBookVCDelegate;

@interface CoreAddressBookVC : UIViewController <
    UITableViewDelegate, UITableViewDataSource,
    UISearchBarDelegate, UISearchDisplayDelegate >


@property (nonatomic,weak) id<CoreAddressBookVCDelegate> delegate;

@end



@protocol CoreAddressBookVCDelegate <NSObject>

@optional

-(void)addressBookVCSelectedContact:(JXPersonInfo *)personInfo;

@end
