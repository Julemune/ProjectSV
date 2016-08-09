#import "GameScene.h"
#import "GameOverScene.h"

#import "SceneManager.h"

#import "Player.h"
#import "Meteor.h"

#define LEFT_FLAT_CONTROL       @"leftFlatControl"
#define RIGHT_FLAT_CONTROL      @"rightFlatControl"
#define SHOT_FLAT_CONTROL       @"shotFlatControl"
#define SHIELD_FLAT_CONTROL     @"shieldFlatControl"
#define LEFT_SHADED_CONTROL     @"leftShadedControl"
#define RIGHT_SHADED_CONTROL    @"rightShadedControl"
#define SHOT_SHADED_CONTROL     @"shotShadedControl"
#define SHIELD_SHADED_CONTROL   @"shieldShadedControl"

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
@property (assign, nonatomic) BOOL shotControlPressed;
@property (assign, nonatomic) BOOL shieldControlPressed;

@property (strong, nonatomic) Player *player;
@property (assign, nonatomic) NSInteger lastPlayerHealth;

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
            [self playerShot];
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
    
    [[SceneManager sharedSceneManager] moveSceneWithScene:self];
    
    if (self.starCounter > 20) {
        [self addChild:[[SceneManager sharedSceneManager] generateStarWithViewSize:self.size]];
        self.starCounter = 0;
    } else {
        self.starCounter ++;
    }
    
    [self generateMeteor];
    
    [self controlsActions];
    [self checkPlayerHealth];
    
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
            [meteor explosionAndRemoveFromParrentOnPoint:contact.contactPoint];
        }
        
        [contact.bodyA.node removeFromParent];
        
        SKSpriteNode *expl = [SKSpriteNode spriteNodeWithImageNamed:@"laserBlue08"];
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
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    self.starCounter = 0;
    self.meteorCounter = 400;
    self.meteorCounterMaxValue = 400;
    
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
    rightControl.position = CGPointMake(leftControl.position.x + leftControl.size.width + 10, 10);
    [self addChild:rightControl];
    
    SKSpriteNode *shotControl = [self createControlWithName:SHOT_SHADED_CONTROL pressedControlName:SHOT_FLAT_CONTROL];
    shotControl.position = CGPointMake(self.size.width - shotControl.size.width - shotControl.size.width / 2, 10);
    [self addChild:shotControl];
    
    SKSpriteNode *shieldControl = [self createControlWithName:SHIELD_SHADED_CONTROL pressedControlName:SHIELD_FLAT_CONTROL];
    shieldControl.position = CGPointMake(self.size.width - shieldControl.size.width - 10, shotControl.position.y + shotControl.size.height + 10);
    [self addChild:shieldControl];
    
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
    
    if (self.lastPlayerHealth >= self.player.health) {
        [self childNodeWithName:[NSString stringWithFormat:@"health%ld", (long)self.lastPlayerHealth]].alpha = 0.5;
        self.lastPlayerHealth = self.player.health;
    }
    if (self.lastPlayerHealth <= self.player.health) {
        [self childNodeWithName:[NSString stringWithFormat:@"health%ld", (long)self.lastPlayerHealth]].alpha = 1;
        self.lastPlayerHealth = self.player.health;
    }
    if (self.player.health == 0) {
        [self presentGameOver];
    }
    
}

- (void)playerShot {
    
    if (![self childNodeWithName:PLAYER_LASER]) {
        SKSpriteNode *playerLaser = [SKSpriteNode spriteNodeWithImageNamed:@"laserBlue04"];
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
    }
    
}

#pragma mark - Enemy

- (void)generateMeteor {
    
    NSInteger maxValue;

    if (arc4random_uniform(2))
        maxValue = self.meteorCounterMaxValue + arc4random_uniform((uint32_t)(self.meteorCounterMaxValue));
    else
        maxValue = self.meteorCounterMaxValue - arc4random_uniform((uint32_t)(self.meteorCounterMaxValue));
    
    if (self.meteorCounter > maxValue) {
        NSInteger meteorIndex = arc4random_uniform(12)+1;
        Meteor *meteor = [Meteor spriteNodeWithImageNamed:[NSString stringWithFormat:@"meteor%ld", (long)meteorIndex] type:meteorIndex > 6 ? meteorGreyType : meteorBrownType];
        meteor.position = CGPointMake((arc4random() % (uint32_t)self.size.width), self.size.height + meteor.size.height);
        meteor.zPosition = 5;
        meteor.zRotation = (M_PI_2 / 180) * arc4random_uniform(361);
        [meteor setScale:0.8];
        
        meteor.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:meteor.size.width/2];
        meteor.physicsBody.categoryBitMask = meteorCategory;
        meteor.physicsBody.collisionBitMask = meteorCategory;
        meteor.physicsBody.contactTestBitMask = meteorCategory;
        
        NSInteger moveDuration = arc4random_uniform(6)+6;
        
        SKAction *moveYAction = [SKAction moveToY:0 - meteor.size.width duration:moveDuration];
        [meteor runAction:moveYAction];
        
        NSInteger moveX;
            if (arc4random_uniform(2))
                moveX = meteor.position.x + arc4random_uniform(meteor.size.width);
            else
                moveX = meteor.position.x - arc4random_uniform(meteor.size.width);
        SKAction *moveXAction = [SKAction moveToX:moveX duration:moveDuration];
        [meteor runAction:moveXAction withKey:@"moveXAction"];
        
        if (meteorIndex == 5 || meteorIndex == 6 || meteorIndex == 11 || meteorIndex == 12) {
            meteor.health = 1;
        } else {
            meteor.health = 3;
        }
        
        [self addChild:meteor];
        
        self.meteorCounter = 0;
    } else {
        self.meteorCounter++;
    }
    
}

@end
