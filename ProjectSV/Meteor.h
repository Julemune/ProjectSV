#import <SpriteKit/SpriteKit.h>

typedef enum {
    meteorGreyType,
    meteorBrownType,
} MeteorType;

@interface Meteor : SKSpriteNode

@property (assign, nonatomic) MeteorType meteorType;

@property (assign, nonatomic) NSInteger health;

+ (Meteor *)spriteNodeWithImageNamed:(NSString *)name type:(MeteorType)type;

- (void)explosionAndRemoveFromParrentOnPoint:(CGPoint)onPoint;

@end
