//
//  GameScene.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import "GameScene.h"

#import "Player.h"

#define BACKGROUND_SPRITE_1 @"backgroundSprite1"
#define BACKGROUND_SPRITE_2 @"backgroundSprite2"

#define LEFT_FLAT_CONTROL       @"leftFlatControl"
#define RIGHT_FLAT_CONTROL      @"rightFlatControl"
#define SHOT_FLAT_CONTROL       @"shotFlatControl"
#define SHIELD_FLAT_CONTROL     @"shieldFlatControl"
#define LEFT_SHADED_CONTROL     @"leftShadedControl"
#define RIGHT_SHADED_CONTROL    @"rightShadedControl"
#define SHOT_SHADED_CONTROL     @"shotShadedControl"
#define SHIELD_SHADED_CONTROL   @"shieldShadedControl"

#define PLAYER @"player";

@interface GameScene()

@property (assign, nonatomic) BOOL contentCreated;
@property (assign, nonatomic) BOOL leftControlPressed;
@property (assign, nonatomic) BOOL rightControlPressed;
@property (assign, nonatomic) BOOL shotControlPressed;
@property (assign, nonatomic) BOOL shieldControlPressed;

@property (strong, nonatomic) Player *player;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];
        
        if (CGRectContainsPoint([self childNodeWithName:LEFT_SHADED_CONTROL].frame, location)) {
            [[self childNodeWithName:LEFT_SHADED_CONTROL] childNodeWithName:LEFT_FLAT_CONTROL].hidden = NO;
            self.leftControlPressed = YES;
        }
        if (CGRectContainsPoint([self childNodeWithName:RIGHT_SHADED_CONTROL].frame, location)) {
            [[self childNodeWithName:RIGHT_SHADED_CONTROL] childNodeWithName:RIGHT_FLAT_CONTROL].hidden = NO;
            self.rightControlPressed = YES;
        }
        if (CGRectContainsPoint([self childNodeWithName:SHOT_SHADED_CONTROL].frame, location)) {
            [[self childNodeWithName:SHOT_SHADED_CONTROL] childNodeWithName:SHOT_FLAT_CONTROL].hidden = NO;
            self.shotControlPressed = YES;
        }
        if (CGRectContainsPoint([self childNodeWithName:SHIELD_SHADED_CONTROL].frame, location)) {
            [[self childNodeWithName:SHIELD_SHADED_CONTROL] childNodeWithName:SHIELD_FLAT_CONTROL].hidden = NO;
            self.shieldControlPressed = YES;
        }
        
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    if (self.leftControlPressed) {
        [[self childNodeWithName:LEFT_SHADED_CONTROL] childNodeWithName:LEFT_FLAT_CONTROL].hidden = YES;
        self.leftControlPressed = NO;
    }
    if (self.rightControlPressed) {
        [[self childNodeWithName:RIGHT_SHADED_CONTROL] childNodeWithName:RIGHT_FLAT_CONTROL].hidden = YES;
        self.rightControlPressed = NO;
    }
    if (self.shotControlPressed) {
        [[self childNodeWithName:SHOT_SHADED_CONTROL] childNodeWithName:SHOT_FLAT_CONTROL].hidden = YES;
        self.shotControlPressed = NO;
    }
    if (self.shieldControlPressed) {
        [[self childNodeWithName:SHIELD_SHADED_CONTROL] childNodeWithName:SHIELD_FLAT_CONTROL].hidden = YES;
        self.shieldControlPressed = NO;
    }
    
}

- (void)update:(NSTimeInterval)currentTime {
    
    [self moveBackground];
    
    if (self.leftControlPressed && self.player.position.x - (self.player.size.width / 2) > 0) {
        self.player.position = CGPointMake(self.player.position.x - self.player.speed, self.player.position.y);
    }
    if (self.rightControlPressed && self.player.position.x + (self.player.size.width / 2) < self.size.width) {
        self.player.position = CGPointMake(self.player.position.x + self.player.speed, self.player.position.y);
    }
    
}

#pragma mark - Methods

- (void)createSceneContents {
    
    [self createControls];
    [self createBackground];
    
    self.player = [Player spriteNodeWithImageNamed:@"player"];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height/5);
    self.player.zPosition = 5;
    [self.player setScale:0.2];
    
    self.player.speed = 8;
    
    self.player.name = PLAYER;
    [self addChild:self.player];
    
}

- (void)createControls {
    
    //Left control
    SKSpriteNode *leftControl = [SKSpriteNode spriteNodeWithImageNamed:LEFT_SHADED_CONTROL];
    
    leftControl.anchorPoint = CGPointMake(0, 0);
    leftControl.position = CGPointMake(10, 10);
    leftControl.zPosition = 10;
    leftControl.name = LEFT_SHADED_CONTROL;
    [leftControl setScale:0.8];
    
    [self addChild:leftControl];
    
    SKSpriteNode *leftControlPressed = [SKSpriteNode spriteNodeWithImageNamed:LEFT_FLAT_CONTROL];
    
    leftControlPressed.anchorPoint = CGPointMake(0, 0);
    leftControlPressed.position = CGPointMake(0, 0);
    leftControlPressed.zPosition = 10;
    leftControlPressed.name = LEFT_FLAT_CONTROL;
    [leftControlPressed setScale:1];
    leftControlPressed.hidden = YES;
    
    [leftControl addChild:leftControlPressed];
    
    //Right control
    SKSpriteNode *rightControl = [SKSpriteNode spriteNodeWithImageNamed:RIGHT_SHADED_CONTROL];
    
    rightControl.anchorPoint = CGPointMake(0, 0);
    rightControl.position = CGPointMake(leftControl.position.x + leftControl.size.width + 10, 10);
    rightControl.zPosition = 10;
    rightControl.name = RIGHT_SHADED_CONTROL;
    [rightControl setScale:0.8];
    
    [self addChild:rightControl];
    
    SKSpriteNode *rightControlPressed = [SKSpriteNode spriteNodeWithImageNamed:RIGHT_FLAT_CONTROL];
    
    rightControlPressed.anchorPoint = CGPointMake(0, 0);
    rightControlPressed.position = CGPointMake(0, 0);
    rightControlPressed.zPosition = 10;
    rightControlPressed.name = RIGHT_FLAT_CONTROL;
    [rightControlPressed setScale:1];
    rightControlPressed.hidden = YES;
    
    [rightControl addChild:rightControlPressed];
    
    //Shot control
    SKSpriteNode *shotControl = [SKSpriteNode spriteNodeWithImageNamed:SHOT_SHADED_CONTROL];
    
    shotControl.anchorPoint = CGPointMake(0, 0);
    shotControl.position = CGPointMake(self.size.width - shotControl.size.width - shotControl.size.width / 2, 10);
    shotControl.zPosition = 10;
    shotControl.name = SHOT_SHADED_CONTROL;
    [shotControl setScale:0.8];
    
    [self addChild:shotControl];
    
    SKSpriteNode *shotControlPressed = [SKSpriteNode spriteNodeWithImageNamed:SHOT_FLAT_CONTROL];
    
    shotControlPressed.anchorPoint = CGPointMake(0, 0);
    shotControlPressed.position = CGPointMake(0, 0);
    shotControlPressed.zPosition = 10;
    shotControlPressed.name = SHOT_FLAT_CONTROL;
    [shotControlPressed setScale:1];
    shotControlPressed.hidden = YES;
    
    [shotControl addChild:shotControlPressed];
    
    //Shield control
    SKSpriteNode *shieldControl = [SKSpriteNode spriteNodeWithImageNamed:SHIELD_SHADED_CONTROL];
    
    shieldControl.anchorPoint = CGPointMake(0, 0);
    shieldControl.position = CGPointMake(self.size.width - shieldControl.size.width, shotControl.position.y + shotControl.size.height + 10);
    shieldControl.zPosition = 10;
    shieldControl.name = SHIELD_SHADED_CONTROL;
    [shieldControl setScale:0.8];
    
    [self addChild:shieldControl];
    
    SKSpriteNode *shieldControlPressed = [SKSpriteNode spriteNodeWithImageNamed:SHIELD_FLAT_CONTROL];
    
    shieldControlPressed.anchorPoint = CGPointMake(0, 0);
    shieldControlPressed.position = CGPointMake(0, 0);
    shieldControlPressed.zPosition = 10;
    shieldControlPressed.name = SHIELD_FLAT_CONTROL;
    [shieldControlPressed setScale:1];
    shieldControlPressed.hidden = YES;
    
    [shieldControl addChild:shieldControlPressed];
    
}

- (void)createBackground {
    
    SKTexture *backgroundTexture = [BasicScene createTitleTextureWithImageNamed:@"purple"
                                                                   coverageSize:CGSizeMake(self.size.width, self.size.height)
                                                                    textureSize:CGRectMake(0, 0, 256, 256)];
    
    SKSpriteNode *backgroundSprite1 = [BasicScene createFirstBackgroundSpriteWithName:BACKGROUND_SPRITE_1 texture:backgroundTexture];
    [self addChild:backgroundSprite1];
    
    
    SKSpriteNode *backgroundSprite2 = [BasicScene createSecondBackgroundSpriteWithName:BACKGROUND_SPRITE_2 texture:backgroundTexture firstSprite:backgroundSprite1];
    [self addChild:backgroundSprite2];
    
}

- (void)moveBackground {
    
    SKSpriteNode *backgroundSprite1 = (SKSpriteNode *)[self childNodeWithName:BACKGROUND_SPRITE_1];
    SKSpriteNode *backgroundSprite2 = (SKSpriteNode *)[self childNodeWithName:BACKGROUND_SPRITE_2];
    [BasicScene moveBackgroundWithFirstSprite:backgroundSprite1 secondSprite:backgroundSprite2];
    
}

@end
