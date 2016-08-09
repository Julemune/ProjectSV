#import "MenuScene.h"
#import "GameScene.h"

#import "SceneManager.h"

#define PLAYER_SHIP_1   @"playerShip1"
#define PLAYER_SHIP_2   @"playerShip2"
#define PLAYER_SHIP_3   @"playerShip3"
#define MARK            @"mark"

#define START_GAME_BUTTON   @"startGame"
#define PLAY_BUTTON         @"play"

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
        
        if (CGRectContainsPoint([self childNodeWithName:START_GAME_BUTTON].frame, location)) {
            [[self childNodeWithName:START_GAME_BUTTON] runAction:[SKAction fadeOutWithDuration:0.5] completion:^{
                [[self childNodeWithName:START_GAME_BUTTON] removeFromParent];
                [self presentPlayerSelectScreen];
            }];
        }
        if (CGRectContainsPoint([self childNodeWithName:PLAY_BUTTON].frame, location)) {
            [self presentGameScene];
        }
        if (CGRectContainsPoint([self childNodeWithName:PLAYER_SHIP_1].frame, location)) {
            [self childNodeWithName:MARK].position = CGPointMake([self childNodeWithName:PLAYER_SHIP_1].position.x, [self childNodeWithName:MARK].position.y);
            [SceneManager sharedSceneManager].playerType = playerShip1;
        }
        if (CGRectContainsPoint([self childNodeWithName:PLAYER_SHIP_2].frame, location)) {
            [self childNodeWithName:MARK].position = CGPointMake([self childNodeWithName:PLAYER_SHIP_2].position.x, [self childNodeWithName:MARK].position.y);
            [SceneManager sharedSceneManager].playerType = playerShip2;
        }
        if (CGRectContainsPoint([self childNodeWithName:PLAYER_SHIP_3].frame, location)) {
            [self childNodeWithName:MARK].position = CGPointMake([self childNodeWithName:PLAYER_SHIP_3].position.x, [self childNodeWithName:MARK].position.y);
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
    [[SceneManager sharedSceneManager] createBackgroundWithScene:self imageNamed:BACKGROUND_BLUE];
    
    [self createMenuItems];
    [SceneManager sharedSceneManager].playerType = playerShip2;
    
}

- (void)createMenuItems {
    
    SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithText:@"Start Game"];
    
    startGameLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    startGameLabel.zPosition = 5;
    startGameLabel.fontName = FONT_FUTURE;
    startGameLabel.fontSize = 30;
    startGameLabel.fontColor = [SKColor whiteColor];
    startGameLabel.name = START_GAME_BUTTON;
    
    [self addChild:startGameLabel];
    
}

- (void)presentPlayerSelectScreen {
    
    float gridX = self.size.width / 4;
    float gridY = self.size.height / 4;
    
    SKSpriteNode *playerShip1 = [self playerShipWithName:PLAYER_SHIP_1 position:CGPointMake(gridX, gridY*3-(gridY/4))];
    [self addChild:playerShip1];
    
    SKSpriteNode *playerShip2 = [self playerShipWithName:PLAYER_SHIP_2 position:CGPointMake(gridX*2, gridY*3-(gridY/4))];
    [self addChild:playerShip2];
    
    SKSpriteNode *playerShip3 = [self playerShipWithName:PLAYER_SHIP_3 position:CGPointMake(gridX*3, gridY*3-(gridY/4))];
    [self addChild:playerShip3];
    
    SKSpriteNode *mark = [SKSpriteNode spriteNodeWithImageNamed:MARK];
    mark.position = CGPointMake(playerShip2.position.x, gridY*2);
    mark.zPosition = 5;
    mark.name = MARK;
    mark.alpha = 0;
    [mark setScale:0.4];
    SKAction *scaleMin  = [SKAction scaleBy:0.8 duration:0.5];
    SKAction *scaleMax  = [SKAction scaleBy:1.25 duration:0.5];
    SKAction *sequence  = [SKAction sequence:@[scaleMin, scaleMax]];
    SKAction *repeat    = [SKAction repeatActionForever:sequence];
    SKAction *fadeIn    = [SKAction fadeInWithDuration:1];
    SKAction *group     = [SKAction group:@[repeat, fadeIn]];
    [mark runAction:group];
    [self addChild:mark];
    
    SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithText:@"Play"];
    startGameLabel.position = CGPointMake(gridX*2,gridY);
    startGameLabel.zPosition = 5;
    startGameLabel.fontName = FONT_FUTURE;
    startGameLabel.fontSize = 30;
    startGameLabel.fontColor = [SKColor whiteColor];
    startGameLabel.alpha = 0;
    startGameLabel.name = PLAY_BUTTON;
    [startGameLabel runAction:[SKAction fadeInWithDuration:1]];
    [self addChild:startGameLabel];
    
}

- (SKSpriteNode *)playerShipWithName:(NSString *)name position:(CGPoint)position {
    
    SKTexture *texture = [SKTexture textureWithImageNamed:name];
    SKSpriteNode *playerShip = [SKSpriteNode spriteNodeWithTexture:texture];
    playerShip.position = position;
    playerShip.zPosition = 5;
    [playerShip setScale:0.8];
    playerShip.name = name;
    playerShip.alpha = 0;
    [playerShip runAction:[SKAction fadeInWithDuration:1]];
    return playerShip;
    
}

- (void)presentGameScene {
    
    SKScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    SKTransition *fadeTransition = [SKTransition fadeWithDuration:1];
    [self.view presentScene:gameScene transition:fadeTransition];
    
}

@end
