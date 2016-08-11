#import <SpriteKit/SpriteKit.h>

@interface Enemy : SKSpriteNode

@property (assign, nonatomic) NSInteger health;
@property (assign, nonatomic) NSInteger scoreWeight;

- (void)explosionAndRemoveFromParrentOnPoint:(CGPoint)onPoint;

@end
