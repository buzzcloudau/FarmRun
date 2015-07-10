// GKLocalPlayerHack.m
// Issue with GameKit and Swift
// http://stackoverflow.com/questions/24045244/game-center-not-authenticating-using-swift

#import "GKLocalPlayerHack.h"

@implementation GKLocalPlayerHack

GKLocalPlayer *getLocalPlayer(void)
{
	return [GKLocalPlayer localPlayer];
}

@end