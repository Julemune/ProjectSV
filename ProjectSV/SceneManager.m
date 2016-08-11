#import "SceneManager.h"

@implementation SceneManager

+ (SceneManager *)sharedSceneManager {
    
    static SceneManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SceneManager alloc] init];
    });
    
    return manager;
}

- (void)createBackgroundWithScene:(SKScene *)scene imageNamed:(NSString *)name {
    
    SKTexture *backgroundTexture = [self createTitleTextureWithImageNamed:name
                                                             coverageSize:CGSizeMake(scene.size.width, scene.size.height)
                                                              textureSize:CGRectMake(0, 0, 256, 256)];
    
    SKSpriteNode *backgroundSprite1 = [self createFirstBackgroundSpriteWithName:BACKGROUND_SPRITE_1 texture:backgroundTexture];
    [scene addChild:backgroundSprite1];
    
    SKSpriteNode *backgroundSprite2 = [self createSecondBackgroundSpriteWithName:BACKGROUND_SPRITE_2 texture:backgroundTexture firstSprite:backgroundSprite1];
    
    [scene addChild:backgroundSprite2];
    
}

- (void)moveSceneWithScene:(SKScene *)scene speed:(NSInteger)speed {
    
    SKSpriteNode *backgroundSprite1 = (SKSpriteNode *)[scene childNodeWithName:BACKGROUND_SPRITE_1];
    SKSpriteNode *backgroundSprite2 = (SKSpriteNode *)[scene childNodeWithName:BACKGROUND_SPRITE_2];
    
    [self moveBackgroundWithFirstSprite:backgroundSprite1 secondSprite:backgroundSprite2 speed:speed];
    
}

- (SKTexture *)createTitleTextureWithImageNamed:(NSString *)name coverageSize:(CGSize)coverageSize textureSize:(CGRect)textureSize {
    
    CGImageRef backgroundCGImage = [UIImage imageNamed:name].CGImage;
    UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
    UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
    
    return backgroundTexture;
    
}

- (SKSpriteNode *)createFirstBackgroundSpriteWithName:(NSString *)name texture:(SKTexture *)texture {
    
    SKSpriteNode *backgroundSprite = [SKSpriteNode spriteNodeWithTexture:texture];
    
    backgroundSprite.position = CGPointMake(0, 0);
    backgroundSprite.anchorPoint = CGPointZero;
    
    backgroundSprite.name = name;
    
    return backgroundSprite;
    
}

- (SKSpriteNode *)createSecondBackgroundSpriteWithName:(NSString *)name texture:(SKTexture *)texture firstSprite:(SKSpriteNode *)firstSprite {
    
    SKSpriteNode *backgroundSprite = [SKSpriteNode spriteNodeWithTexture:texture];
    
    backgroundSprite.position = CGPointMake(0, firstSprite.size.height-1);
    backgroundSprite.anchorPoint = CGPointZero;
    
    backgroundSprite.name = name;
    
    return backgroundSprite;
    
}

- (void)moveBackgroundWithFirstSprite:(SKSpriteNode *)backgroundSprite1 secondSprite:(SKSpriteNode *)backgroundSprite2 speed:(NSInteger )speed {
    
    backgroundSprite1.position = CGPointMake(backgroundSprite1.position.x, backgroundSprite1.position.y-speed);
    backgroundSprite2.position = CGPointMake(backgroundSprite2.position.x, backgroundSprite2.position.y-speed);
    
    if (backgroundSprite1.position.y < -backgroundSprite1.size.height)
        backgroundSprite1.position = CGPointMake(backgroundSprite2.position.x, backgroundSprite2.position.y + backgroundSprite1.size.height);
    
    if (backgroundSprite2.position.y < -backgroundSprite2.size.height)
        backgroundSprite2.position = CGPointMake(backgroundSprite1.position.x, backgroundSprite1.position.y + backgroundSprite2.size.height);
    
}

- (void)generateBasicStars:(SKScene *)scene {
    
    for (int i = 1; i <= 10; i++) {
        
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"star%d", arc4random_uniform(3)+1]];
        
        int lowerBound = (scene.size.height / 10 * (i-1));
        int upperBound = scene.size.height / 10 * i;
        int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        
        star.position = CGPointMake((arc4random() % (uint32_t)scene.size.width), rndValue);
        star.zPosition = 1;
        star.alpha = 0.6;
        [star setScale:0.4];
        
        SKAction *moveAction = [SKAction moveToY:star.position.y - scene.size.height duration:5];
        [star runAction:moveAction completion:^{
            [star removeFromParent];
        }];
        
        [scene addChild:star];
        
    }
    
}

- (SKSpriteNode *)generateStarWithViewSize:(CGSize)size {
        
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"star%d", arc4random_uniform(3)+1]];
    star.position = CGPointMake((arc4random() % (uint32_t)size.width), size.height + star.size.height);
    star.zPosition = 1;
    star.alpha = 0.6;
    [star setScale:0.4];
    
    SKAction *moveAction = [SKAction moveToY:0 - star.size.width duration:5];
    [star runAction:moveAction completion:^{
        [star removeFromParent];
    }];
        
    return star;
    
}

- (SKSpriteNode *)generateStarWithViewSize:(CGSize)size speedDelta:(float)speedDelta {
    
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"star%d", arc4random_uniform(3)+1]];
    star.position = CGPointMake((arc4random() % (uint32_t)size.width), size.height + star.size.height);
    star.zPosition = 1;
    star.alpha = 0.6;
    [star setScale:0.4];
    
    SKAction *moveAction = [SKAction moveToY:0 - star.size.width duration:5-(speedDelta+speedDelta)];
    [star runAction:moveAction completion:^{
        [star removeFromParent];
    }];
    
    return star;
    
}

@end
