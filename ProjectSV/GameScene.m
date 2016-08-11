#import "GameScene.h"
#import "GameOverScene.h"

#import "SceneManager.h"

#import "Player.h"
#import "Meteor.h"
#import "Enemy.h"

#define LEFT_FLAT_CONTROL       @"leftFlatControl"
#define RIGHT_FLAT_CONTROL      @"rightFlatControl"
#define LEFT_SHADED_CONTROL     @"leftShadedControl"
#define RIGHT_SHADED_CONTROL    @"rightShadedControl"

#define SCORE @"score"

#define PLAYER          @"player"
#define PLAYER_LASER    @"playerLaser"

#define POWER_UP_PILL   @"pill"
#define POWER_UP_SHIELD @"shield"

@import AVFoundation;

static const uint32_t playerCategory            =  0x1 << 0;
static const uint32_t playerLaserCategory       =  0x1 << 1;
static const uint32_t meteorCategory            =  0x1 << 2;
static const uint32_t enemyCategory             =  0x1 << 3;
static const uint32_t powerUpCategory           =  0x1 << 4;

@interface GameScene() <SKPhysicsContactDelegate>

@property (strong, nonatomic) AVAudioPlayer *backgroundAudioPlayer;

@property (assign, nonatomic) BOOL contentCreated;
@property (assign, nonatomic) NSInteger backgroundSpeed;
@property (assign, nonatomic) NSInteger starCounter;
@property (assign, nonatomic) BOOL gameOver;

@property (assign, nonatomic) BOOL leftControlPressed;
@property (assign, nonatomic) BOOL rightControlPressed;

@property (assign, nonatomic) NSInteger gameScore;
@property (assign, nonatomic) float gameScoreCounter;
@property (assign, nonatomic) NSInteger currentLevel;
@property (assign, nonatomic) float complexityDelta;

@property (assign, nonatomic) float pillCounter;
@property (assign, nonatomic) float shieldCounter;

@property (strong, nonatomic) Player *player;
@property (assign, nonatomic) BOOL shield;
@property (assign, nonatomic) NSInteger laserCounter;

@property (assign, nonatomic) NSInteger meteorCounter;
@property (assign, nonatomic) NSInteger meteorCounterMaxValue;

@property (assign, nonatomic) NSInteger enemyCounter;
@property (assign, nonatomic) NSInteger enemyCounterMaxValue;
@property (assign, nonatomic) NSInteger counterOfEnemies;
@property (assign, nonatomic) NSInteger counterOfEnemiesMaxValue;

@end

@implementation GameScene

#pragma mark - SKScene

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    self.rightControlPressed    = NO;
    self.leftControlPressed     = NO;
    
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
    
    [self countGameScore:1];
    
    [[SceneManager sharedSceneManager] moveSceneWithScene:self speed:self.backgroundSpeed];
    
    if (self.starCounter > 20) {
        [self addChild:[[SceneManager sharedSceneManager] generateStarWithViewSize:self.size speedDelta:self.complexityDelta]];
        self.starCounter = 0;
    } else {
        self.starCounter ++;
    }
    
    [self generateMeteor];
    [self generateEnemy];
    [self checkControlsForPressed];
    [self checkPlayerHealth];
    [self playerShot];
    
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {

    if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == meteorCategory) {
        Meteor *meteor = (Meteor *)contact.bodyB.node;
        [meteor explosionAndRemoveFromParrentOnPoint:contact.contactPoint];
        if (!self.shield) {
            self.player.health--;
        }
    }
    
    if (contact.bodyA.categoryBitMask == playerLaserCategory && contact.bodyB.categoryBitMask == meteorCategory) {
        Meteor *meteor = (Meteor *)contact.bodyB.node;
        meteor.health = meteor.health - self.player.laserDamage;
        if (meteor.health <= 0) {
            [self countGameScore:meteor.scoreWeight];
            [meteor explosionAndRemoveFromParrentOnPoint:contact.contactPoint];
        }
        
        [contact.bodyA.node removeFromParent];
        
        SKSpriteNode *expl  = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"laserRedExpl%d", arc4random_uniform(4)+1]];
        expl.position       = contact.contactPoint;
        expl.zPosition      = 6;
        [expl setScale:0.8];
        [expl runAction:[SKAction waitForDuration:0.1] completion:^{
            [expl removeFromParent];
        }];
        [self addChild:expl];
    }
    
    if (contact.bodyA.categoryBitMask == playerLaserCategory && contact.bodyB.categoryBitMask == enemyCategory) {
        Enemy *enemy = (Enemy *)contact.bodyB.node;
        enemy.health = enemy.health - self.player.laserDamage;
        if (enemy.health <= 0) {
            [self countGameScore:enemy.scoreWeight];
            [enemy explosionAndRemoveFromParrentOnPoint:contact.contactPoint];
            self.counterOfEnemies--;
        }
        
        [contact.bodyA.node removeFromParent];
        
        SKSpriteNode *expl  = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"laserRedExpl%d", arc4random_uniform(4)+1]];
        expl.position       = contact.contactPoint;
        expl.zPosition      = 6;
        [expl setScale:0.8];
        [expl runAction:[SKAction waitForDuration:0.1] completion:^{
            [expl removeFromParent];
        }];
        [self addChild:expl];
        
    }
    
    if (contact.bodyA.categoryBitMask == meteorCategory && contact.bodyB.categoryBitMask == meteorCategory) {
        [contact.bodyA.node removeActionForKey:@"moveXAction"];
        [contact.bodyB.node removeActionForKey:@"moveXAction"];
    }
    
    if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == powerUpCategory) {
        if ([contact.bodyB.node.name isEqualToString:POWER_UP_PILL]) {
            [contact.bodyB.node removeFromParent];
            self.player.health++;
        }
        
        if ([contact.bodyB.node.name isEqualToString:POWER_UP_SHIELD]) {
            self.shield = YES;
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"playerShield%f", contact.bodyB.node.speed]];
            shield.zPosition = 6;
            [shield setScale:0.8];
            SKAction *duration = [SKAction waitForDuration:15.f + (contact.bodyB.node.speed*15)];
            [shield runAction:duration completion:^{
                [shield removeFromParent];
                self.shield = NO;
            }];
            [self.player addChild:shield];
            [contact.bodyB.node removeFromParent];
        }
    }

}

#pragma mark - SetUp Methods

- (void)createSceneContents {
    
//    NSError *err;
//    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"backgroundMusic.wav" ofType:nil]];
//    self.backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
//    if (err) {
//        NSLog(@"error in audio play %@",[err userInfo]);
//        return;
//    }
//    [self.backgroundAudioPlayer prepareToPlay];
//    self.backgroundAudioPlayer.numberOfLoops = -1;
//    [self.backgroundAudioPlayer setVolume:1.0];
//    [self.backgroundAudioPlayer play];
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    self.gameScore          = 0;
    self.gameScoreCounter   = 0;
    self.currentLevel       = 1;
    self.complexityDelta    = 1.0;
    
    self.backgroundSpeed    = 1;
    self.starCounter        = 0;
    
    self.pillCounter        = 0;
    self.shieldCounter      = 0;
    
    self.laserCounter       = 0;
    
    self.meteorCounter              = 500;
    self.meteorCounterMaxValue      = 1000;
    self.enemyCounter               = 1000;
    self.enemyCounterMaxValue       = 1500;
    self.counterOfEnemies           = 0;
    self.counterOfEnemiesMaxValue   = 2;
    
    [[SceneManager sharedSceneManager] generateBasicStars:self];
    [[SceneManager sharedSceneManager] createBackgroundWithScene:self imageNamed:BACKGROUND_PURPLE];
    
    SKLabelNode *gameScoreLabel = [SKLabelNode labelNodeWithFontNamed:FONT_FUTURE];
    gameScoreLabel.fontColor    = [SKColor whiteColor];
    gameScoreLabel.text         = [NSString stringWithFormat:@"SCORE: %ld", (long)self.gameScore];
    gameScoreLabel.fontSize     = 20;
    gameScoreLabel.position     = CGPointMake(CGRectGetMidX(self.frame), self.size.height - gameScoreLabel.frame.size.height);
    gameScoreLabel.zPosition    = 10;
    gameScoreLabel.name         = SCORE;
    [self addChild:gameScoreLabel];
    
    [self createControls];
    [self createPlayer];
    [self createHealthBar];
    
    [self presentLevel];
    
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

- (void)checkControlsForPressed {
    
    if (!self.gameOver) {
        if (self.leftControlPressed && self.player.position.x - (self.player.size.width / 2) > 0) {
            self.player.position = CGPointMake(self.player.position.x - self.player.speed, self.player.position.y);
        }
        if (self.rightControlPressed && self.player.position.x + (self.player.size.width / 2) < self.size.width) {
            self.player.position = CGPointMake(self.player.position.x + self.player.speed, self.player.position.y);
        }
    }
    
}

- (void)createHealthBar {
    
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

- (void)presentLevel {
    
    SKLabelNode *levelLabel  = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"LEVEL %ld", (long)self.currentLevel]];
    levelLabel.position      = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    levelLabel.zPosition     = 12;
    levelLabel.fontName      = FONT_FUTURE;
    levelLabel.fontSize      = 40;
    levelLabel.fontColor     = [SKColor whiteColor];
    [levelLabel runAction:[SKAction sequence:@[[SKAction waitForDuration:2], [SKAction fadeOutWithDuration:2]]] completion:^{
        [levelLabel removeFromParent];
    }];
    [self addChild:levelLabel];
    
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

#pragma mark - Player

- (void)createPlayer {
    
    self.player = [Player playerWithPlayerType:[SceneManager sharedSceneManager].playerType];
    self.player.position    = CGPointMake(CGRectGetMidX(self.frame), self.size.height/5);
    self.player.zPosition   = 5;
    [self.player setScale:0.8];
    self.player.name        = PLAYER;
    
    self.player.physicsBody = [SKPhysicsBody bodyWithTexture:self.player.texture size:self.player.texture.size];
    self.player.physicsBody.dynamic = NO;
    self.player.physicsBody.categoryBitMask     = playerCategory;
    self.player.physicsBody.collisionBitMask    = meteorCategory | powerUpCategory;
    self.player.physicsBody.contactTestBitMask  = meteorCategory | powerUpCategory;
    
    [self addChild:self.player];
    
}

- (void)checkPlayerHealth {
    
    switch (self.player.health) {
        case 4:
            [self childNodeWithName:@"health4"].alpha = 1;
            [self childNodeWithName:@"health3"].alpha = 1;
            [self childNodeWithName:@"health2"].alpha = 1;
            [self childNodeWithName:@"health1"].alpha = 1;
            break;
        case 3:
            [self childNodeWithName:@"health4"].alpha = 0.5;
            [self childNodeWithName:@"health3"].alpha = 1;
            [self childNodeWithName:@"health2"].alpha = 1;
            [self childNodeWithName:@"health1"].alpha = 1;
            break;
        case 2:
            [self childNodeWithName:@"health4"].alpha = 0.5;
            [self childNodeWithName:@"health3"].alpha = 0.5;
            [self childNodeWithName:@"health2"].alpha = 1;
            [self childNodeWithName:@"health1"].alpha = 1;
            break;
        case 1:
            [self childNodeWithName:@"health4"].alpha = 0.5;
            [self childNodeWithName:@"health3"].alpha = 0.5;
            [self childNodeWithName:@"health2"].alpha = 0.5;
            [self childNodeWithName:@"health1"].alpha = 1;
            break;
        case 0:
            [self childNodeWithName:@"health4"].alpha = 0.5;
            [self childNodeWithName:@"health3"].alpha = 0.5;
            [self childNodeWithName:@"health2"].alpha = 0.5;
            [self childNodeWithName:@"health1"].alpha = 0.5;
            [self presentGameOver];
            break;
        default:
            break;
    }
    
}

- (void)playerShot {
    
    if (self.laserCounter > self.player.laserSpeed || ![self childNodeWithName:PLAYER_LASER]) {
        SKSpriteNode *playerLaser = [SKSpriteNode spriteNodeWithImageNamed:@"laserRed04"];
        playerLaser.anchorPoint = CGPointMake(0.5, 0);
        playerLaser.position = CGPointMake(self.player.position.x, self.player.position.y+self.player.size.height/2);
        playerLaser.zPosition = 5;
        [playerLaser setScale:0.8];
        playerLaser.name = PLAYER_LASER;
        
        playerLaser.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:playerLaser.size];
        playerLaser.physicsBody.allowsRotation = NO;
        playerLaser.physicsBody.categoryBitMask = playerLaserCategory;
        playerLaser.physicsBody.collisionBitMask = meteorCategory | enemyCategory;
        playerLaser.physicsBody.contactTestBitMask = meteorCategory | enemyCategory;
        
        [playerLaser runAction:[SKAction moveToY:self.size.height duration:1] completion:^{
            [playerLaser removeFromParent];
        }];
        [self addChild:playerLaser];
        self.laserCounter = 0;
    } else {
        self.laserCounter++;
    }
    
}

#pragma mark - Game Methods

- (void)countGameScore:(NSInteger)value {
    
    SKLabelNode *label  = (SKLabelNode *)[self childNodeWithName:SCORE];
    self.gameScore      = self.gameScore + value;
    
    //Level Up
    if (self.gameScore / 2000 > self.gameScoreCounter) {
        self.complexityDelta = self.complexityDelta + 0.2;
        self.backgroundSpeed++;
        self.currentLevel++;
        self.counterOfEnemiesMaxValue++;
        [self presentLevel];
        self.gameScoreCounter = self.gameScoreCounter + 1.0;
    }
    //Spawn pill
    if (self.gameScore / 2500 > self.pillCounter) {
        self.pillCounter = self.pillCounter + 1.0;
        [self generatePill];
    }
    //Spawn shiels
    if (self.gameScore / 3000 > self.shieldCounter) {
        self.shieldCounter = self.shieldCounter + 1.0;
        [self generateShield];
    }
    
    label.text = [NSString stringWithFormat:@"SCORE: %ld", (long)self.gameScore];
    
}

#pragma mark - Power-ups

- (void)generatePill {
    
    NSInteger rndPill = arc4random_uniform(4)+1;
    
    SKSpriteNode *pill = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"pill%ld", (long)rndPill]];
    pill.position = CGPointMake(arc4random_uniform((uint32_t)self.size.width), self.size.height + pill.size.height);
    pill.zPosition = 5;
    [pill setScale:0.8];
    pill.name = POWER_UP_PILL;
    
    pill.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pill.size];
    pill.physicsBody.categoryBitMask = powerUpCategory;
    pill.physicsBody.collisionBitMask = playerCategory;
    
    SKAction *moveYAction = [SKAction moveToY:0 - pill.size.width duration:8];
    [pill runAction:moveYAction completion:^{
        [pill removeFromParent];
    }];
    
    [self addChild:pill];
    
}

- (void)generateShield {
    
    NSInteger rndShield = arc4random_uniform(3)+1;
    
    SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"shield%ld", (long)rndShield]];
    shield.position = CGPointMake(arc4random_uniform((uint32_t)self.size.width), self.size.height + shield.size.height);
    shield.zPosition = 5;
    [shield setScale:0.8];
    shield.name = POWER_UP_SHIELD;
    shield.speed = rndShield;
    
    shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shield.size];
    shield.physicsBody.categoryBitMask = powerUpCategory;
    shield.physicsBody.collisionBitMask = playerCategory;
    
    SKAction *moveYAction = [SKAction moveToY:0 - shield.size.width duration:8];
    [shield runAction:moveYAction completion:^{
        [shield removeFromParent];
    }];
    
    [self addChild:shield];
    
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
        
        NSInteger moveDuration = (arc4random_uniform(3)+9)/self.complexityDelta;
        
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
            meteor.scoreWeight = 50;
        } else {
            meteor.health = 3;
            meteor.scoreWeight = 100;
        }
        
        [self addChild:meteor];
        
        self.meteorCounter = 0;
    } else {
        self.meteorCounter++;
    }
    
}

- (void)generateEnemy {
    
    NSInteger maxValue;
    
    if (arc4random_uniform(2))
        maxValue = self.enemyCounterMaxValue + arc4random_uniform((uint32_t)(self.enemyCounterMaxValue));
    else
        maxValue = self.enemyCounterMaxValue - arc4random_uniform((uint32_t)(self.enemyCounterMaxValue));
    
    if (self.enemyCounter > maxValue/self.complexityDelta && self.counterOfEnemies < self.counterOfEnemiesMaxValue) {
        
        Enemy *enemy = [Enemy spriteNodeWithImageNamed:@"enemyBlack1"];
        
        enemy.position = CGPointMake((arc4random() % (uint32_t)self.size.width), self.size.height + enemy.size.height);
        enemy.zPosition = 5;
        [enemy setScale:0.8];
        
        enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemy.size.width/2-enemy.size.width/8];
        enemy.physicsBody.categoryBitMask = enemyCategory;
        enemy.physicsBody.collisionBitMask = playerLaserCategory;
        
        enemy.health = 2;
        enemy.scoreWeight = 100;
        
        SKAction *randomMovement = [SKAction runBlock:^(void){
            SKAction *move = [SKAction moveTo:CGPointMake(arc4random_uniform(self.size.width),
                                                           arc4random_uniform(self.size.height/2)+self.size.height/2) duration:5.0];
            [enemy runAction:move];
        }];
        SKAction *wait = [SKAction waitForDuration:5.0];
        SKAction *sequence = [SKAction sequence:@[randomMovement, wait]];
        SKAction *repeat = [SKAction repeatActionForever:sequence];
        [enemy runAction:repeat];
        [self addChild:enemy];
        
        self.counterOfEnemies++;
        self.enemyCounter = 0;
    } else {
        self.enemyCounter++;
    }
    
}

@end
