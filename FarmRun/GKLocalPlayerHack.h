//  GKLocalPlayerHack.h
// Issue with GameKit and Swift
// http://stackoverflow.com/questions/24045244/game-center-not-authenticating-using-swift

#import <GameKit/GameKit.h>

@interface GKLocalPlayerHack : NSObject

GKLocalPlayer *getLocalPlayer(void);

@end
