#import "Meteor.h"

@implementation Meteor

+ (Meteor *)spriteNodeWithImageNamed:(NSString *)name type:(MeteorType)type {
    
    Meteor *meteor = [super spriteNodeWithImageNamed:name];
    meteor.meteorType = type;
    
    return meteor;
}

- (void)explosionAndRemoveFromParrentOnPoint:(CGPoint)onPoint {
    
    self.physicsBody = nil;
    
    NSString *meteorTypeString;
    if (self.meteorType == meteorBrownType) {
        meteorTypeString = @"meteorBrown";
    } else {
        meteorTypeString = @"meteorGrey";
    }
    
    for (int i = 0; i < 6; i++) {
        SKSpriteNode *meteor = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@%d", meteorTypeString, arc4random_uniform(2)+1]];
        meteor.position = onPoint;
        meteor.zPosition = 6;
        meteor.zRotation = (M_PI_2 / 180) * arc4random_uniform(361);
        
        SKAction *moveX = [SKAction moveToX:self.position.x+arc4random_uniform(101)-50 duration:1.5];
        SKAction *moveY = [SKAction moveToY:self.position.y+arc4random_uniform(101)-50 duration:1.5];
        
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *hide = [SKAction fadeOutWithDuration:0.5];
        SKAction *sequence = [SKAction sequence:@[wait, hide]];
        
        SKAction *group = [SKAction group:@[moveX, moveY, sequence]];
        
        [meteor runAction:group completion:^{
            [meteor removeFromParent];
        }];
        
        [self.parent addChild:meteor];
    }
    
    [self removeFromParent];
    
}

@end
