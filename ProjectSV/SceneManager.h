#import <SpriteKit/SpriteKit.h>
#import "Player.h"

#define FONT_FUTURE         @"KenVector Future"
#define FONT_FUTURE_THIN    @"KenVector Future Thin"

#define BACKGROUND_BLACK        @"black"
#define BACKGROUND_BLUE         @"blue"
#define BACKGROUND_DARKPURPLE   @"darkPurple"
#define BACKGROUND_PURPLE       @"purple"

#define BACKGROUND_SPRITE_1 @"backgroundSprite1"
#define BACKGROUND_SPRITE_2 @"backgroundSprite2"

@interface SceneManager : SKScene

@property (assign, nonatomic) PlayerType playerType;

+ (SceneManager *)sharedSceneManager;

- (void)createBackgroundWithScene:(SKScene *)scene imageNamed:(NSString *)name;
- (void)moveSceneWithScene:(SKScene *)scene;

- (void)generateBasicStars:(SKScene *)scene;
- (SKSpriteNode *)generateStarWithViewSize:(CGSize)size;
- (SKSpriteNode *)generateStarWithViewSize:(CGSize)size speedDelta:(float)speedDelta;

@end
