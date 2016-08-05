//
//  MenuScene.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"

@interface MenuScene()

@property (assign, nonatomic) BOOL contentCreated;

@property (strong, nonatomic) GameScene *gameScene;

@end

@implementation MenuScene

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];
        
        if (CGRectContainsPoint([self childNodeWithName:@"StartGame"].frame, location)) {
            
            [self presentGameScene];
            
        }
        
    }
    
}

#pragma mark - Methods

- (void)createSceneContents {
    
    SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithText:@"Start Game"];
    
    startGameLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    startGameLabel.fontName = @"KenVector Future";
    startGameLabel.fontSize = 20;
    startGameLabel.fontColor = [SKColor whiteColor];
    startGameLabel.name = @"StartGame";
    
    [self addChild:startGameLabel];
    
}

- (void)presentGameScene {
    
    self.gameScene = [[GameScene alloc] initWithSize:self.size];
    SKTransition *doorsTransition = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:self.gameScene transition:doorsTransition];
    
}

@end
