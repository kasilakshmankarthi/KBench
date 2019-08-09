//
//  ViewController.m
//  test_app
//
//  Created by Andy White on 1/4/19.
//  Copyright © 2019 Andy White. All rights reserved.
//

#import "ViewController.h"
#import "syncPrimitives.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Custom setup and test
    [self setup];

    //Use the last run for reporting cycles_per_iteration
    for( int runs = 1; runs <= 3; runs++) {
        [self measure_test:runs];
        [self spin_delay];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)spin_delay {
    for(int i = 0; i < 1e9; i++) {
        asm volatile("nop\n");
    }
}

- (void)setup {
    // Sleep for 2 seconds to allow PMUs to begin counting
    sleep(2);

    // Run for some time to transition to big core
    [self spin_delay];
}


// Filter results by this symbol
- (void)measure_test:(int) runs {
    runSyncPrimitives();
}


@end
