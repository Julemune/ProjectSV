//
//  GameViewController.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright (c) 2016 Julemune. All rights reserved.
//

#import "GameViewController.h"
#import "MenuScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    MenuScene *scene = [[MenuScene alloc] initWithSize:self.view.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscapeLeft;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
    
}

@end
