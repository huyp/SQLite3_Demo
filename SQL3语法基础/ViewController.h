//
//  ViewController.h
//  SQL3语法基础
//
//  Created by 彦鹏 on 15/11/24.
//  Copyright © 2015年 Huyp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *text1;
@property (weak, nonatomic) IBOutlet UITextField *text2;

- (IBAction)insert:(id)sender;

- (IBAction)drop:(id)sender;

- (IBAction)update:(id)sender;

- (IBAction)select:(id)sender;

- (IBAction)selectWhere:(id)sender;

- (IBAction)del:(id)sender;

@end

