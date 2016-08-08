#import <SpriteKit/SpriteKit.h>
#import "Player.h"

#define BACKGROUND_SPRITE_1 @"backgroundSprite1"
#define BACKGROUND_SPRITE_2 @"backgroundSprite2"

@interface SceneManager : SKScene

@property (assign, nonatomic) PlayerType playerType;

+ (SceneManager *)sharedSceneManager;

- (void)createBackgroundWithScene:(SKScene *)scene imageNamed:(NSString *)name;
- (void)moveSceneWithScene:(SKScene *)scene;

- (void)generateBasicStars:(SKScene *)scene;
- (SKSpriteNode *)generateStarWithViewSize:(CGSize)size;

@end
