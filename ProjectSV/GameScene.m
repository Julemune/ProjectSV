//
//  GameScene.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import "GameScene.h"

#import "Player.h"

#define BACKGROUND_SPRITE_1 @"BackgroundSprite1"
#define BACKGROUND_SPRITE_2 @"BackgroundSprite2"

@interface GameScene()

@property (assign, nonatomic) BOOL contentCreated;

@property (strong, nonatomic) Player *player;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
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
    SKTexture *backgroundTexture = [BasicScene createTitleTextureWithImageNamed:@"purple"
                                                                   coverageSize:CGSizeMake(self.size.width, self.size.height)
                                                                    textureSize:CGRectMake(0, 0, 256, 256)];
    
    SKSpriteNode *backgroundSprite1 = [BasicScene createFirstBackgroundSpriteWithName:BACKGROUND_SPRITE_1 texture:backgroundTexture];
    [self addChild:backgroundSprite1];
    
    
    SKSpriteNode *backgroundSprite2 = [BasicScene createSecondBackgroundSpriteWithName:BACKGROUND_SPRITE_2 texture:backgroundTexture firstSprite:backgroundSprite1];
    [self addChild:backgroundSprite2];
    
}

@end
