#import "MenuScene.h"
#import "GameScene.h"

#import "SceneManager.h"

#define PLAYER_SHIP_1 @"playerShip1";
#define PLAYER_SHIP_2 @"playerShip2";
#define PLAYER_SHIP_3 @"playerShip3";

@interface MenuScene()

@property (assign, nonatomic) BOOL contentCreated;
@property (assign, nonatomic) NSInteger starCounter;

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
            [[self childNodeWithName:@"StartGame"] removeFromParent];
            [self playerSelectScreen];
        }
        if (CGRectContainsPoint([self childNodeWithName:@"Play"].frame, location)) {
            [self presentGameScene];
        }
        if (CGRectContainsPoint([self childNodeWithName:@"playerShip1"].frame, location)) {
            [self childNodeWithName:@"mark"].position = CGPointMake([self childNodeWithName:@"playerShip1"].position.x, [self childNodeWithName:@"mark"].position.y);
            [SceneManager sharedSceneManager].playerType = playerShip1;
        }
        if (CGRectContainsPoint([self childNodeWithName:@"playerShip2"].frame, location)) {
            [self childNodeWithName:@"mark"].position = CGPointMake([self childNodeWithName:@"playerShip2"].position.x, [self childNodeWithName:@"mark"].position.y);
            [SceneManager sharedSceneManager].playerType = playerShip2;
        }
        if (CGRectContainsPoint([self childNodeWithName:@"playerShip3"].frame, location)) {
            [self childNodeWithName:@"mark"].position = CGPointMake([self childNodeWithName:@"playerShip3"].position.x, [self childNodeWithName:@"mark"].position.y);
            [SceneManager sharedSceneManager].playerType = playerShip3;
        }
        
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
    
    
}

#pragma mark - Methods

- (void)createSceneContents {
    
    self.starCounter = 0;
    [[SceneManager sharedSceneManager] generateBasicStars:self];
    [[SceneManager sharedSceneManager] createBackgroundWithScene:self imageNamed:@"blue"];
    
    [self createMenuItems];
    [SceneManager sharedSceneManager].playerType = playerShip2;
    
}

- (void)createMenuItems {
    
    SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithText:@"Start Game"];
    
    startGameLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    startGameLabel.zPosition = 5;
    startGameLabel.fontName = @"KenVector Future";
    startGameLabel.fontSize = 30;
    startGameLabel.fontColor = [SKColor whiteColor];
    startGameLabel.name = @"StartGame";
    
    [self addChild:startGameLabel];
    
}

- (void)playerSelectScreen {
    
    float gridX = self.size.width / 4;
    float gridY = self.size.height / 4;
    
    SKTexture *texture1 = [SKTexture textureWithImageNamed:@"playerShip1"];
    SKSpriteNode *playerShip1 = [SKSpriteNode spriteNodeWithTexture:texture1];
    playerShip1.position = CGPointMake(gridX, gridY*3-(gridY/4));
    playerShip1.zPosition = 5;
    [playerShip1 setScale:0.8];
    playerShip1.name = PLAYER_SHIP_1;
    [self addChild:playerShip1];
    
    SKTexture *texture2 = [SKTexture textureWithImageNamed:@"playerShip2"];
    SKSpriteNode *playerShip2 = [SKSpriteNode spriteNodeWithTexture:texture2];
    playerShip2.position = CGPointMake(gridX*2, gridY*3-(gridY/4));
    playerShip2.zPosition = 5;
    [playerShip2 setScale:0.8];
    playerShip2.name = PLAYER_SHIP_2;
    [self addChild:playerShip2];
    
    SKTexture *texture3 = [SKTexture textureWithImageNamed:@"playerShip3"];
    SKSpriteNode *playerShip3 = [SKSpriteNode spriteNodeWithTexture:texture3];
    playerShip3.position = CGPointMake(gridX*3, gridY*3-(gridY/4));
    playerShip3.zPosition = 5;
    [playerShip3 setScale:0.8];
    playerShip3.name = PLAYER_SHIP_3;
    [self addChild:playerShip3];
    
    SKSpriteNode *mark = [SKSpriteNode spriteNodeWithImageNamed:@"mark"];
    mark.position = CGPointMake(playerShip2.position.x, gridY*2);
    mark.zPosition = 5;
    mark.name = @"mark";
    [mark setScale:0.4];
    SKAction *scl1 = [SKAction scaleBy:0.8 duration:0.5];
    SKAction *scl2 = [SKAction scaleBy:1.25 duration:0.5];
    SKAction *sequence = [SKAction sequence:@[scl1, scl2]];
    SKAction *repeat = [SKAction repeatActionForever:sequence];
    [mark runAction:repeat];
    [self addChild:mark];
    
    SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithText:@"Play"];
    
    startGameLabel.position = CGPointMake(gridX*2,gridY);
    startGameLabel.zPosition = 5;
    startGameLabel.fontName = @"KenVector Future";
    startGameLabel.fontSize = 30;
    startGameLabel.fontColor = [SKColor whiteColor];
    startGameLabel.name = @"Play";
    [self addChild:startGameLabel];
    
}

- (void)presentGameScene {
    
    SKScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    SKTransition *doorsTransition = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:gameScene transition:doorsTransition];
    
}

@end
