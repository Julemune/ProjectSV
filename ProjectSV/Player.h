//
//  Player.h
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    playerShip1,
    playerShip2,
    playerShip3
} PlayerType;

@interface Player : SKSpriteNode

@property (assign, nonatomic) NSInteger health;

+ (Player *)playerWithPlayerType:(PlayerType)type;

@end
