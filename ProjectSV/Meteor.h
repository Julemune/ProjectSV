#import <SpriteKit/SpriteKit.h>

typedef enum {
    meteorGreyType,
    meteorBrownType,
} MeteorType;

@interface Meteor : SKSpriteNode

@property (assign, nonatomic) MeteorType meteorType;

@property (assign, nonatomic) NSInteger health;
@property (assign, nonatomic) NSInteger scoreWeight;

+ (Meteor *)spriteNodeWithImageNamed:(NSString *)name type:(MeteorType)type;

- (void)explosionAndRemoveFromParrentOnPoint:(CGPoint)onPoint;

@end
