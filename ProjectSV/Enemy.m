#import "Enemy.h"

@implementation Enemy

- (void)explosionAndRemoveFromParrentOnPoint:(CGPoint)onPoint {
    
    self.physicsBody = nil;
    [self removeFromParent];
    
}

@end
