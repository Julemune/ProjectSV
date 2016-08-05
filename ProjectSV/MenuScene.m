//
//  MenuScene.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"

#define BACKGROUND_SPRITE_1 @"backgroundSprite1"
#define BACKGROUND_SPRITE_2 @"backgroundSprite2"

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

- (void)update:(NSTimeInterval)currentTime {
    
    SKSpriteNode *backgroundSprite1 = (SKSpriteNode *)[self childNodeWithName:BACKGROUND_SPRITE_1];
    SKSpriteNode *backgroundSprite2 = (SKSpriteNode *)[self childNodeWithName:BACKGROUND_SPRITE_2];
    
    [BasicScene moveBackgroundWithFirstSprite:backgroundSprite1 secondSprite:backgroundSprite2];
    
}

#pragma mark - Methods

- (void)createSceneContents {
    
    //Create background
    SKTexture *backgroundTexture = [BasicScene createTitleTextureWithImageNamed:@"blue"
                                                             coverageSize:CGSizeMake(self.size.width, self.size.height)
                                                              textureSize:CGRectMake(0, 0, 256, 256)];
    
    SKSpriteNode *backgroundSprite1 = [BasicScene createFirstBackgroundSpriteWithName:BACKGROUND_SPRITE_1 texture:backgroundTexture];
    [self addChild:backgroundSprite1];
    
    SKSpriteNode *backgroundSprite2 = [BasicScene createSecondBackgroundSpriteWithName:BACKGROUND_SPRITE_2 texture:backgroundTexture firstSprite:backgroundSprite1];
    [self addChild:backgroundSprite2];
    
    //Create menu items
    SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithText:@"Start Game"];
    
    startGameLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    startGameLabel.zPosition = 5;
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
