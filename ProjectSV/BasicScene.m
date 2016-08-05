//
//  BasicScene.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import "BasicScene.h"

@implementation BasicScene

+ (SKTexture *)createTitleTextureWithImageNamed:(NSString *)name coverageSize:(CGSize)coverageSize textureSize:(CGRect)textureSize {
    
    CGImageRef backgroundCGImage = [UIImage imageNamed:name].CGImage;
    UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
    UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
    
    return backgroundTexture;
    
}

+ (SKSpriteNode *)createFirstBackgroundSpriteWithName:(NSString *)name texture:(SKTexture *)texture {
    
    SKSpriteNode *backgroundSprite = [SKSpriteNode spriteNodeWithTexture:texture];
    
    backgroundSprite.position = CGPointMake(0, 0);
    backgroundSprite.anchorPoint = CGPointZero;
    
    backgroundSprite.name = name;
    
    return backgroundSprite;
    
}

+ (SKSpriteNode *)createSecondBackgroundSpriteWithName:(NSString *)name texture:(SKTexture *)texture firstSprite:(SKSpriteNode *)firstSprite {
    
    SKSpriteNode *backgroundSprite = [SKSpriteNode spriteNodeWithTexture:texture];
    
    backgroundSprite.position = CGPointMake(0, firstSprite.size.height-1);
    backgroundSprite.anchorPoint = CGPointZero;
    
    backgroundSprite.name = name;
    
    return backgroundSprite;
    
}

+ (void)moveBackgroundWithFirstSprite:(SKSpriteNode *)backgroundSprite1 secondSprite:(SKSpriteNode *)backgroundSprite2 {
    
    backgroundSprite1.position = CGPointMake(backgroundSprite1.position.x, backgroundSprite1.position.y-4);
    backgroundSprite2.position = CGPointMake(backgroundSprite2.position.x, backgroundSprite2.position.y-4);
    
    if (backgroundSprite1.position.y < -backgroundSprite1.size.height)
        backgroundSprite1.position = CGPointMake(backgroundSprite2.position.x, backgroundSprite2.position.y + backgroundSprite1.size.height);
    
    if (backgroundSprite2.position.y < -backgroundSprite2.size.height)
        backgroundSprite2.position = CGPointMake(backgroundSprite1.position.x, backgroundSprite1.position.y + backgroundSprite2.size.height);
    
}

@end
