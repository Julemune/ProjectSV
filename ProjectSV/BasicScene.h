//
//  BasicScene.h
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BasicScene : SKScene

+ (SKTexture *)createTitleTextureWithImageNamed:(NSString *)name coverageSize:(CGSize)coverageSize textureSize:(CGRect)textureSize;

+ (SKSpriteNode *)createFirstBackgroundSpriteWithName:(NSString *)name texture:(SKTexture *)texture;
+ (SKSpriteNode *)createSecondBackgroundSpriteWithName:(NSString *)name texture:(SKTexture *)texture firstSprite:(SKSpriteNode *)firstSprite;

+ (void)moveBackgroundWithFirstSprite:(SKSpriteNode *)backgroundSprite1 secondSprite:(SKSpriteNode *)backgroundSprite2;

@end
