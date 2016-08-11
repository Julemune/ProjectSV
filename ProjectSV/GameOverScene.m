#import "GameOverScene.h"
#import "MenuScene.h"

#import "SceneManager.h"

@interface GameOverScene()

@property (assign, nonatomic) BOOL contentCreated;
@property (assign, nonatomic) NSInteger starCounter;

@end

@implementation GameOverScene

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self presentMenuScene];
}

- (void)update:(NSTimeInterval)currentTime {
    
    [[SceneManager sharedSceneManager] moveSceneWithScene:self speed:1];
    
    if (self.starCounter > 20) {
        [self addChild:[[SceneManager sharedSceneManager] generateStarWithViewSize:self.size]];
        self.starCounter = 0;
    } else {
        self.starCounter ++;
    }
    
}

#pragma mark - Methods

- (void)createSceneContents {
    
    self.starCounter = 0;
    
    [[SceneManager sharedSceneManager] generateBasicStars:self];
    [[SceneManager sharedSceneManager] createBackgroundWithScene:self imageNamed:BACKGROUND_BLACK];
    
    [self createMenuItems];
    
}

- (void)createMenuItems {
    
    SKLabelNode *gameOverLabel  = [SKLabelNode labelNodeWithText:@"GAME OVER"];
    gameOverLabel.position      = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+30);
    gameOverLabel.zPosition     = 12;
    gameOverLabel.fontName      = FONT_FUTURE;
    gameOverLabel.fontSize      = 40;
    gameOverLabel.fontColor     = [SKColor whiteColor];
    [self addChild:gameOverLabel];
    
    SKLabelNode *goBackLabel    = [SKLabelNode labelNodeWithText:@"Tap to go to menu"];
    goBackLabel.position        = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-30);
    goBackLabel.zPosition       = 12;
    goBackLabel.fontName        = FONT_FUTURE;
    goBackLabel.fontSize        = 25;
    goBackLabel.fontColor       = [SKColor whiteColor];
    [self addChild:goBackLabel];
    
}

- (void)presentMenuScene {
    
    SKScene *menuScene = [[MenuScene alloc] initWithSize:self.size];
    SKTransition *fadeTransition = [SKTransition fadeWithDuration:1];
    [self.view presentScene:menuScene transition:fadeTransition];
    
}

@end
