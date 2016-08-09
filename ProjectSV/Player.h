#import <SpriteKit/SpriteKit.h>

typedef enum {
    playerShip1,
    playerShip2,
    playerShip3
} PlayerType;

@interface Player : SKSpriteNode

@property (assign, nonatomic) PlayerType playerType;

@property (assign, nonatomic) NSInteger health;
@property (assign, nonatomic) NSInteger maxHealth;
@property (assign, nonatomic) NSInteger laserDamage;

+ (Player *)playerWithPlayerType:(PlayerType)type;

@end
