//
//  ViewController.m
//  ImagePicker
//
//  Created by akixie on 17/4/5.
//  Copyright © 2017年 Aki.Xie. All rights reserved.
//

#import "ViewController.h"
#import "TWPhotoPickerController.h"

#define SCREEN_W ([[UIScreen mainScreen] bounds].size.width)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"GetFit";
    
    UILabel *txtLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_W-200)/2, 100, 200, 21)];
    txtLabel.text = @"GetFit-线上私人健身管家";
    txtLabel.textColor = [UIColor redColor];
    [self.view addSubview:txtLabel];
    
    
    UIButton *pickerButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_W-80)/2, 150, 80, 50)];
    [pickerButton setTitle:@"图片选择" forState:UIControlStateNormal];
    pickerButton.backgroundColor = [UIColor grayColor];
    [pickerButton addTarget:self action:@selector(imagePickerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickerButton];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)imagePickerAction:(id)sender {
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    photoPicker.isModel = YES;
    UINavigationController *photoPockerNav = [[UINavigationController alloc] initWithRootViewController:photoPicker];
    [self presentViewController:photoPockerNav animated:YES completion:NULL];

}


@end
