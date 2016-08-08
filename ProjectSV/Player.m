//
//  Player.m
//  ProjectSV
//
//  Created by Julemune on 05.08.16.
//  Copyright © 2016 Julemune. All rights reserved.
//

#import "Player.h"

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
    
    switch (type) {
        case playerShip1:
            player.speed = 5;
            break;
        case playerShip2:
            player.speed = 8;
            break;
        case playerShip3:
            player.speed = 11;
            break;
        default:
            player.speed = 8;
            break;
    }
    
    return player;
}

@end
