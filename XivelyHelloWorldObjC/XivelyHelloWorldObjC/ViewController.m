//
//  ViewController.m
//  XivelyHelloWorldObjC
//
//  Copyright © 2015 Xively. All rights reserved.
//

#import "ViewController.h"
#import "XivelyHelloWorld.h"

@interface ViewController ()

@property(nonatomic, strong)XivelyHelloWorld *helloWorld;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onHelloWorldPressed {
    [self.helloWorld stop];
    self.helloWorld = [[XivelyHelloWorld alloc] init];
    [self.helloWorld start];
}

@end
