//
//  Player.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import "Player.h"

@interface Player ()

@end

@implementation Player

+ (Player *)playerWithPlayerType:(PlayerType)type{
    
    NSString *name = nil;
    
    switch (type) {
        case playerShip1:
            name = @"playerShip1";
            break;
        case playerShip2:
            name = @"playerShip2";
            break;
        case playerShip3:
            name = @"playerShip3";
            break;
        default:
            name = @"playerShip2";
            break;
    }
    
    Player *player = [super spriteNodeWithImageNamed:name];
    player.playerType = type;
    
    switch (type) {
        case playerShip1:
            player.speed = 5;
            player.maxHealth = 4;
            break;
        case playerShip2:
            player.speed = 8;
            player.maxHealth = 3;
            break;
        case playerShip3:
            player.speed = 11;
            player.maxHealth = 2;
            break;
        default:
            player.speed = 8;
            player.maxHealth = 3;
            break;
    }
    
    player.health = player.maxHealth;
    
    return player;
}

- (void)setHealth:(NSInteger)health {
    if (health <= self.maxHealth && health >= 0) {
        _health = health;
    }
    if (health == 0) {
        NSMutableArray *flashArray = [NSMutableArray new];
        for (int i = 1; i < 7; i++)
            [flashArray addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"explosion%d", i]]];
        [self runAction:[SKAction animateWithTextures:flashArray timePerFrame:0.5]];
    }
}

@end
