#import "GameScene.h"
#import "MenuScene.h"

#import "SceneManager.h"

#import "Player.h"

#define LEFT_FLAT_CONTROL       @"leftFlatControl"
#define RIGHT_FLAT_CONTROL      @"rightFlatControl"
#define SHOT_FLAT_CONTROL       @"shotFlatControl"
#define SHIELD_FLAT_CONTROL     @"shieldFlatControl"
#define LEFT_SHADED_CONTROL     @"leftShadedControl"
#define RIGHT_SHADED_CONTROL    @"rightShadedControl"
#define SHOT_SHADED_CONTROL     @"shotShadedControl"
#define SHIELD_SHADED_CONTROL   @"shieldShadedControl"

#define GO_BACK_BUTTON @"goBackButton"

#define PLAYER @"player"

@interface GameScene()

@property (assign, nonatomic) BOOL contentCreated;
@property (assign, nonatomic) BOOL gameOver;
@property (assign, nonatomic) NSInteger starCounter;

@property (assign, nonatomic) BOOL leftControlPressed;
@property (assign, nonatomic) BOOL rightControlPressed;
@property (assign, nonatomic) BOOL shotControlPressed;
@property (assign, nonatomic) BOOL shieldControlPressed;

@property (strong, nonatomic) Player *player;
@property (assign, nonatomic) NSInteger lastPlayerHealth;

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
            self.player.health++;
        }
        if (CGRectContainsPoint([self childNodeWithName:SHIELD_SHADED_CONTROL].frame, location)) {
            [[self childNodeWithName:SHIELD_SHADED_CONTROL] childNodeWithName:SHIELD_FLAT_CONTROL].hidden = NO;
            self.shieldControlPressed = YES;
            self.player.health--;
        }
        
        if (self.gameOver) {
            [self presentMenuScene];
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
    
    [self controlsActions];
    [self checkPlayerHealth];
    
}

#pragma mark - SetUp Methods

- (void)createSceneContents {
    
    self.starCounter = 0;
    [[SceneManager sharedSceneManager] generateBasicStars:self];
    [[SceneManager sharedSceneManager] createBackgroundWithScene:self imageNamed:@"purple"];
    
    [self createControls];
    
    //Player
    self.player = [Player playerWithPlayerType:[SceneManager sharedSceneManager].playerType];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height/5);
    self.player.zPosition = 5;
    [self.player setScale:0.8];
    
    self.player.name = PLAYER;
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
        health.name = [NSString stringWithFormat:@"healthLow%d", i];
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

- (void)gameOverScreen {
    
    if (!self.gameOver) {
        
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithText:@"GAME OVER"];
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+30);
        gameOverLabel.zPosition = 12;
        gameOverLabel.fontName = @"KenVector Future";
        gameOverLabel.fontSize = 40;
        gameOverLabel.fontColor = [SKColor whiteColor];
        gameOverLabel.alpha = 0;
        [gameOverLabel runAction:[SKAction fadeInWithDuration:1]];
        [self addChild:gameOverLabel];
        
        SKLabelNode *goBackLabel = [SKLabelNode labelNodeWithText:@"Tap to go to menu"];
        goBackLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-30);
        goBackLabel.zPosition = 12;
        goBackLabel.fontName = @"KenVector Future";
        goBackLabel.fontSize = 25;
        goBackLabel.fontColor = [SKColor whiteColor];
        goBackLabel.alpha = 0;
        [goBackLabel runAction:[SKAction fadeInWithDuration:1]];
        [self addChild:goBackLabel];
        
        SKShapeNode *blackScreen = [SKShapeNode shapeNodeWithRect:self.frame];
        blackScreen.fillColor = [SKColor blackColor];
        blackScreen.position = CGPointMake(0, 0);
        blackScreen.zPosition = 11;
        blackScreen.alpha = 0;
        [blackScreen runAction:[SKAction fadeInWithDuration:1]];
        [self addChild:blackScreen];
        
        self.gameOver = YES;
    }
    
}

- (void)presentMenuScene {
    
    SKScene *menuScene = [[MenuScene alloc] initWithSize:self.size];
    SKTransition *doorsTransition = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:menuScene transition:doorsTransition];
    
}

#pragma mark - Game Methods

- (void)checkPlayerHealth {
    
    if (self.lastPlayerHealth >= self.player.health) {
        [self childNodeWithName:[NSString stringWithFormat:@"healthLow%ld", (long)self.lastPlayerHealth]].alpha = 0.5;
        self.lastPlayerHealth = self.player.health;
    }
    if (self.lastPlayerHealth <= self.player.health) {
        [self childNodeWithName:[NSString stringWithFormat:@"healthLow%ld", (long)self.lastPlayerHealth]].alpha = 1;
        self.lastPlayerHealth = self.player.health;
    }
    if (self.player.health == 0) {
        [self gameOverScreen];
    }
    
}

@end
