#import "GameScene.h"
#import "GameOverScene.h"

#import "SceneManager.h"

#import "Player.h"
#import "Meteor.h"

#define LEFT_FLAT_CONTROL       @"leftFlatControl"
#define RIGHT_FLAT_CONTROL      @"rightFlatControl"
#define LEFT_SHADED_CONTROL     @"leftShadedControl"
#define RIGHT_SHADED_CONTROL    @"rightShadedControl"

#define SCORE @"score"

#define PLAYER @"player"
#define PLAYER_LASER @"playerLaser"

static const uint32_t playerCategory            =  0x1 << 0;
static const uint32_t playerLaserCategory       =  0x1 << 1;
static const uint32_t meteorCategory            =  0x1 << 2;

@interface GameScene() <SKPhysicsContactDelegate>

@property (assign, nonatomic) BOOL contentCreated;
@property (assign, nonatomic) BOOL gameOver;

@property (assign, nonatomic) BOOL leftControlPressed;
@property (assign, nonatomic) BOOL rightControlPressed;

@property (assign, nonatomic) NSInteger gameScore;
@property (assign, nonatomic) float complexityDelta;

@property (strong, nonatomic) Player *player;
@property (assign, nonatomic) NSInteger lastPlayerHealth;
@property (assign, nonatomic) NSInteger laserCounter;

@property (assign, nonatomic) NSInteger starCounter;

@property (assign, nonatomic) NSInteger meteorCounter;
@property (assign, nonatomic) NSInteger meteorCounterMaxValue;



@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    self.rightControlPressed = NO;
    self.leftControlPressed = NO;
    
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
        
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];
        
        if (self.leftControlPressed && !CGRectContainsPoint([self childNodeWithName:RIGHT_SHADED_CONTROL].frame, location)) {
            [[self childNodeWithName:LEFT_SHADED_CONTROL] childNodeWithName:LEFT_FLAT_CONTROL].hidden = YES;
            self.leftControlPressed = NO;
        }
        if (self.rightControlPressed && !CGRectContainsPoint([self childNodeWithName:LEFT_SHADED_CONTROL].frame, location)) {
            [[self childNodeWithName:RIGHT_SHADED_CONTROL] childNodeWithName:RIGHT_FLAT_CONTROL].hidden = YES;
            self.rightControlPressed = NO;
        }
        
    }
    
}

- (void)update:(NSTimeInterval)currentTime {
    
    [[SceneManager sharedSceneManager] moveSceneWithScene:self];
    
    if (self.starCounter > 20) {
        [self addChild:[[SceneManager sharedSceneManager] generateStarWithViewSize:self.size speedDelta:self.complexityDelta]];
        self.starCounter = 0;
    } else {
        self.starCounter ++;
    }
    
    [self generateMeteor];
    
    [self controlsActions];
    [self checkPlayerHealth];
    
    [self playerShot];
    
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {

    if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == meteorCategory) {
        Meteor *meteor = (Meteor *)contact.bodyB.node;
        [meteor explosionAndRemoveFromParrentOnPoint:contact.contactPoint];
        self.player.health--;
    }
    
    if (contact.bodyA.categoryBitMask == meteorCategory && contact.bodyB.categoryBitMask == meteorCategory) {
        [contact.bodyA.node removeActionForKey:@"moveXAction"];
        [contact.bodyB.node removeActionForKey:@"moveXAction"];
    }
    
    if (contact.bodyA.categoryBitMask == playerLaserCategory && contact.bodyB.categoryBitMask == meteorCategory) {
        Meteor *meteor = (Meteor *)contact.bodyB.node;
        meteor.health = meteor.health - self.player.laserDamage;
        if (meteor.health <= 0) {
            [self countGameScore:meteor.scoreWeight];
            [meteor explosionAndRemoveFromParrentOnPoint:contact.contactPoint];
        }
        
        [contact.bodyA.node removeFromParent];
        
        SKSpriteNode *expl = [SKSpriteNode spriteNodeWithImageNamed:@"laserRed08"];
        expl.position = contact.contactPoint;
        expl.zPosition = 6;
        [expl setScale:0.8];
        [expl runAction:[SKAction waitForDuration:0.1] completion:^{
            [expl removeFromParent];
        }];
        [self addChild:expl];
    }

}

#pragma mark - SetUp Methods

- (void)createSceneContents {
    
    self.gameScore = 0;
    self.complexityDelta = 1.0;
    SKLabelNode *gameScoreLabel = [SKLabelNode labelNodeWithFontNamed:FONT_FUTURE];
    gameScoreLabel.fontColor = [SKColor whiteColor];
    gameScoreLabel.text = [NSString stringWithFormat:@"SCORE: %ld", (long)self.gameScore];
    gameScoreLabel.name = SCORE;
    gameScoreLabel.position = CGPointMake(self.size.width/2, self.size.height-gameScoreLabel.frame.size.height);
    gameScoreLabel.zPosition = 10;
    gameScoreLabel.fontSize = 20;
    [self addChild:gameScoreLabel];
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    self.laserCounter = 0;
    self.starCounter = 0;
    self.meteorCounter = 500;
    self.meteorCounterMaxValue = 1000;
    
    [[SceneManager sharedSceneManager] generateBasicStars:self];
    [[SceneManager sharedSceneManager] createBackgroundWithScene:self imageNamed:BACKGROUND_PURPLE];
    
    [self createControls];
    
    //Player
    self.player = [Player playerWithPlayerType:[SceneManager sharedSceneManager].playerType];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height/5);
    self.player.zPosition = 5;
    [self.player setScale:0.8];
    self.player.name = PLAYER;
    
    self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
    self.player.physicsBody.dynamic = NO;
    self.player.physicsBody.categoryBitMask = playerCategory;
    self.player.physicsBody.collisionBitMask = meteorCategory;
    self.player.physicsBody.contactTestBitMask = meteorCategory;
    
    [self addChild:self.player];
    
    self.lastPlayerHealth = self.player.health;
    
    //Health bar
    for (int i = 1; i <= self.player.maxHealth; i++) {
        NSString *textureName;
        if (self.player.playerType == playerShip1) {
            textureName = @"playerLife1";
        } else if (self.player.playerType == playerShip2) {
            textureName = @"playerLife2";
        } else if (self.player.playerType == playerShip3) {
            textureName = @"playerLife3";
        }
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        SKSpriteNode *health = [SKSpriteNode spriteNodeWithTexture:texture];
        [health setScale:0.8];
        health.position = CGPointMake(self.size.width - health.size.width*i, self.size.height - health.size.height);
        health.zPosition = 10;
        health.name = [NSString stringWithFormat:@"health%d", i];
        [self addChild:health];
        
    }
    
}

- (void)createControls {

    SKSpriteNode *leftControl = [self createControlWithName:LEFT_SHADED_CONTROL pressedControlName:LEFT_FLAT_CONTROL];
    leftControl.position = CGPointMake(10, 10);
    [self addChild:leftControl];
    
    SKSpriteNode *rightControl = [self createControlWithName:RIGHT_SHADED_CONTROL pressedControlName:RIGHT_FLAT_CONTROL];
    rightControl.position = CGPointMake(self.size.width-rightControl.size.width, 10);
    [self addChild:rightControl];
    
}

- (SKSpriteNode *)createControlWithName:(NSString *)name pressedControlName:(NSString *)pressedName {
    
    SKSpriteNode *control = [SKSpriteNode spriteNodeWithImageNamed:name];
    
    control.anchorPoint = CGPointMake(0, 0);
    control.zPosition = 10;
    control.name = name;
    [control setScale:0.8];
    
    SKSpriteNode *controlPressed = [SKSpriteNode spriteNodeWithImageNamed:pressedName];
    
    controlPressed.anchorPoint = CGPointMake(0, 0);
    controlPressed.position = CGPointMake(0, 0);
    controlPressed.zPosition = 10;
    controlPressed.name = pressedName;
    [controlPressed setScale:1];
    controlPressed.hidden = YES;
    
    [control addChild:controlPressed];
    
    return control;
}

- (void)countGameScore:(NSInteger)value {
    SKLabelNode *label = (SKLabelNode *)[self childNodeWithName:SCORE];
    self.gameScore = self.gameScore + value;
    if (self.gameScore % 100 == 0) {
        self.complexityDelta = self.complexityDelta + 0.1;
    }
    label.text = [NSString stringWithFormat:@"SCORE: %ld", self.gameScore];
}

- (void)controlsActions {
    
    if (!self.gameOver) {
        
        if (self.leftControlPressed && self.player.position.x - (self.player.size.width / 2) > 0) {
            self.player.position = CGPointMake(self.player.position.x - self.player.speed, self.player.position.y);
        }
        
        if (self.rightControlPressed && self.player.position.x + (self.player.size.width / 2) < self.size.width) {
            self.player.position = CGPointMake(self.player.position.x + self.player.speed, self.player.position.y);
        }
        
    }
    
}

- (void)presentGameOver {
    
    if (!self.gameOver) {
        self.gameOver = YES;
            [self runAction:[SKAction waitForDuration:0.4] completion:^{
                SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
                SKTransition *fadeTransition = [SKTransition fadeWithDuration:1];
                [self.view presentScene:gameOverScene transition:fadeTransition];
            }];
    }
    
}

#pragma mark - Game Methods

- (void)checkPlayerHealth {
    
    if (self.lastPlayerHealth > self.player.health) {
        [self childNodeWithName:[NSString stringWithFormat:@"health%ld", (long)self.lastPlayerHealth]].alpha = 0.5;
        
        SKAction *colorize = [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:0.5 duration:2];
        SKAction *unColorize = [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:0 duration:2];
        [self.player runAction:[SKAction sequence:@[colorize, unColorize]]];
        
        self.lastPlayerHealth = self.player.health;
    }
    if (self.lastPlayerHealth < self.player.health) {
        [self childNodeWithName:[NSString stringWithFormat:@"health%ld", (long)self.lastPlayerHealth]].alpha = 1;
        self.lastPlayerHealth = self.player.health;
    }
    if (self.player.health == 0) {
        [self presentGameOver];
    }
    
}

- (void)playerShot {
    
    if (self.laserCounter > self.player.laserSpeed) {
        SKSpriteNode *playerLaser = [SKSpriteNode spriteNodeWithImageNamed:@"laserRed04"];
        playerLaser.anchorPoint = CGPointMake(0.5, 0);
        playerLaser.position = CGPointMake(self.player.position.x, self.player.position.y+self.player.size.height/2);
        playerLaser.zPosition = 5;
        [playerLaser setScale:0.8];
        playerLaser.name = PLAYER_LASER;
        
        playerLaser.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:playerLaser.size];
        playerLaser.physicsBody.categoryBitMask = playerLaserCategory;
        playerLaser.physicsBody.collisionBitMask = meteorCategory;
        playerLaser.physicsBody.contactTestBitMask = meteorCategory;
        
        [playerLaser runAction:[SKAction moveToY:self.size.height duration:1] completion:^{
            [playerLaser removeFromParent];
        }];
        [self addChild:playerLaser];
        self.laserCounter = 0;
    } else {
        self.laserCounter++;
    }
    
}

#pragma mark - Enemy

- (void)generateMeteor {
    
    NSInteger maxValue;

    if (arc4random_uniform(2))
        maxValue = self.meteorCounterMaxValue + arc4random_uniform((uint32_t)(self.meteorCounterMaxValue));
    else
        maxValue = self.meteorCounterMaxValue - arc4random_uniform((uint32_t)(self.meteorCounterMaxValue));
    
    if (self.meteorCounter > maxValue/self.complexityDelta) {
        NSInteger meteorIndex = arc4random_uniform(12)+1;
        Meteor *meteor = [Meteor spriteNodeWithImageNamed:[NSString stringWithFormat:@"meteor%ld", (long)meteorIndex] type:meteorIndex > 6 ? meteorGreyType : meteorBrownType];
        meteor.position = CGPointMake((arc4random() % (uint32_t)self.size.width), self.size.height + meteor.size.height);
        meteor.zPosition = 5;
        meteor.zRotation = (M_PI_2 / 180) * arc4random_uniform(361);
        [meteor setScale:0.8];
        
        meteor.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:meteor.size.width/2-meteor.size.width/8];
        meteor.physicsBody.categoryBitMask = meteorCategory;
        meteor.physicsBody.collisionBitMask = meteorCategory;
        meteor.physicsBody.contactTestBitMask = meteorCategory;
        
        NSInteger moveDuration = (arc4random_uniform(6)+6)/self.complexityDelta;
        
        SKAction *moveYAction = [SKAction moveToY:0 - meteor.size.width duration:moveDuration];
        [meteor runAction:moveYAction completion:^{
            [meteor removeFromParent];
        }];
        
        NSInteger moveX;
            if (arc4random_uniform(2))
                moveX = meteor.position.x + arc4random_uniform(meteor.size.width);
            else
                moveX = meteor.position.x - arc4random_uniform(meteor.size.width);
        SKAction *moveXAction = [SKAction moveToX:moveX duration:moveDuration];
        [meteor runAction:moveXAction withKey:@"moveXAction"];
        
        if (meteorIndex == 5 || meteorIndex == 6 || meteorIndex == 11 || meteorIndex == 12) {
            meteor.health = 1;
            meteor.scoreWeight = 5;
        } else {
            meteor.health = 3;
            meteor.scoreWeight = 10;
        }
        
        [self addChild:meteor];
        
        self.meteorCounter = 0;
    } else {
        self.meteorCounter++;
    }
    
}

@end
