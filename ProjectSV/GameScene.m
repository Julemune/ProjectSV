#import "GameScene.h"

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

#define PLAYER @"player";

@interface GameScene()

@property (assign, nonatomic) BOOL contentCreated;
@property (assign, nonatomic) NSInteger starCounter;

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
    
    [[SceneManager sharedSceneManager] moveSceneWithScene:self];
    
    if (self.starCounter > 20) {
        [self addChild:[[SceneManager sharedSceneManager] generateStarWithViewSize:self.size]];
        self.starCounter = 0;
    } else {
        self.starCounter ++;
    }
    
    [self controlsActions];
    
}

#pragma mark - Methods

- (void)createSceneContents {
    
    self.starCounter = 0;
    [[SceneManager sharedSceneManager] generateBasicStars:self];
    [[SceneManager sharedSceneManager] createBackgroundWithScene:self imageNamed:@"purple"];
    
    [self createControls];
    
    self.player = [Player playerWithPlayerType:[SceneManager sharedSceneManager].playerType];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height/5);
    self.player.zPosition = 5;
    [self.player setScale:0.8];
    
    self.player.name = PLAYER;
    [self addChild:self.player];
    
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
    
    if (self.leftControlPressed && self.player.position.x - (self.player.size.width / 2) > 0) {
        self.player.position = CGPointMake(self.player.position.x - self.player.speed, self.player.position.y);
    }
    
    if (self.rightControlPressed && self.player.position.x + (self.player.size.width / 2) < self.size.width) {
        self.player.position = CGPointMake(self.player.position.x + self.player.speed, self.player.position.y);
    }
    
}

@end
