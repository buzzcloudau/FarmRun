//
//  GameScene.swift
//  FarmRun
//
//  Created by Ricardo Russon on 10/11/2014.
//  Copyright (c) 2014 BuzzCloud. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate, GKLocalPlayerListener {
    
    let player = SKSpriteNode(imageNamed:"pigwalk1")
	let scoreLabel = SKLabelNode(fontNamed:"MarkerFelt-Wide")

    var zeroPoint:CGFloat!
    var outsideWidth:CGFloat!
	var outsideHeight:CGFloat!

	var score:Int = 0
    
    var platforms:SKNode! = SKNode()

    var movePlatformsAndRemove:SKAction!
    
    var playerX:CGFloat = 0
    var gameOver:Bool = true
    var canJump:Bool = false
    var continueJump:Bool = false
	var canFly:Bool = false
    var playerSpeed:CGFloat = 50
    var playerFixLeft:Int = 0
    var gamePlaying:Bool = false
    var selfFrame:CGSize = CGSizeMake(10, 10)
    
    let playerCategory:UInt32 = 1 << 0
    let platformTopCategory:UInt32 = 1 << 1
    let platformBottomCategory:UInt32 = 1 << 2
    let platformCategory:UInt32 = 1 << 3
    let groundCategory:UInt32 = 1 << 4
	let platformScoreCategory:UInt32 = 1 << 5
	let platformBadPickupCategory:UInt32 = 1 << 6
	let platformMobCategory:UInt32 = 1 << 7
	let platformTrapCategory:UInt32 = 1 << 8

	let vibrateSound:SystemSoundID = UInt32(kSystemSoundID_Vibrate)

	let jumpSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("jump", ofType: "m4a")!)
	var jumpSoundPlayer = AVAudioPlayer()

	let dieSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ground", ofType: "m4a")!)
	var dieSoundPlayer = AVAudioPlayer()

	let introSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("intro", ofType: "m4a")!)
	var introSoundPlayer = AVAudioPlayer()

	let bgSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("game_bg_music", ofType: "m4a")!)
	var bgSoundPlayer = AVAudioPlayer()

	let scoreSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Rise02", ofType: "mp3")!)
	var scoreSoundPlayer = AVAudioPlayer()

	var pigWalkingTextureArray = NSMutableArray()
	var pigJumpingTextureArray = NSMutableArray()
	var pigFlyingTextureArray = NSMutableArray()
	var appleTextureArray = NSMutableArray()

	var canRestart:Bool = false

	var bannerView:GADBannerView?
	var timer:NSTimer?
	var loadRequestAllowed = true
	var bannerDisplayed = false
	let statusbarHeight:CGFloat = 20.0
	var leaderboardIdentifier:String = "farmrun.lb"
	var gameCenterEnabled: Bool = false
	var currentAnim:NSString = ""
	var lastNode:SKNode!
	var currentLevel = 0
	var levelSteps:Int? = 10
	var levelPosition = 0
	var levelPlatformPosition = 0
	var levelPreviousHeight:CGFloat = 0
	var levelPreviousSpacer:CGFloat = 0
	var level_preserveHeight:Int? = 0
	var level_hasTop:Int? = 0
	var level_hasBottom:Int? = 0
	var level_touchTop:Int? = 0
	var level_touchBottom:Int? = 0
	var level_platformGap:Int? = 0
	var level_platformCount:Int? = 0
	var level_offsetTop:Int? = 0
	var level_offsetBottom:Int? = 0
	var level_badPickupRate:Int? = 0
	var level_mobRate:Int? = 0
	var level_platformImage:Array<String>?
	var level_platformWidth:Int? = 0
	var level_platformHasPhysics:Int? = 0
	var level_hasPickups:Int? = 0

	var localPlayer:GKLocalPlayer = getLocalPlayer() // see GKLocalPlayerHack.h
	var leaderBoard:GKLeaderboard = GKLeaderboard()

	var imageCache:Dictionary<String, SKTexture> = [
		"pigwalk1" : SKTexture(imageNamed: "pigwalk1")
		, "pigwalk2" : SKTexture(imageNamed: "pigwalk2")
		, "pigwalk3" : SKTexture(imageNamed: "pigwalk3")
		, "pigfly1" : SKTexture(imageNamed: "pigfly1")
		, "pigfly2" : SKTexture(imageNamed: "pigfly2")
		, "pigjump" : SKTexture(imageNamed: "pigjump")
		, "apple1" : SKTexture(imageNamed: "apple1")
		, "apple2" : SKTexture(imageNamed: "apple2")
		, "apple3" : SKTexture(imageNamed: "apple3")
		, "apple4" : SKTexture(imageNamed: "apple4")
		, "platformWater" : SKTexture(imageNamed: "platformWater")
		, "platformWater_2" : SKTexture(imageNamed: "platformWater_2")
		, "platformWater_3" : SKTexture(imageNamed: "platformWater_3")
		, "platformWater_4" : SKTexture(imageNamed: "platformWater_4")
		, "platformWater_5" : SKTexture(imageNamed: "platformWater_5")
		, "platformWater_6" : SKTexture(imageNamed: "platformWater_6")
		, "platformWater_7" : SKTexture(imageNamed: "platformWater_7")
		, "platformWater_8" : SKTexture(imageNamed: "platformWater_8")
		, "platformWater_9" : SKTexture(imageNamed: "platformWater_9")
		, "platformWater_10" : SKTexture(imageNamed: "platformWater_10")
		, "platformWater_11" : SKTexture(imageNamed: "platformWater_11")
		, "platformWater_12" : SKTexture(imageNamed: "platformWater_12")
	]

	let leaderboardBtn:SKSpriteNode = SKSpriteNode(imageNamed: "buttonLeaderboard")
	let startBtn:SKSpriteNode = SKSpriteNode(imageNamed: "buttonStart")
	let keyStore = NSUbiquitousKeyValueStore() //iCloud.buzzcloud.farmrun

	override func didMoveToView(view: SKView) {

		self.physicsWorld.contactDelegate = self

        selfFrame = view.bounds.size
        zeroPoint = CGFloat(self.size.height / 2)
        outsideWidth = scene?.size.width
		outsideHeight = scene?.size.height
        
        backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.9, alpha: 1.0)
        
		canRestart = true

		jumpSoundPlayer = AVAudioPlayer(contentsOfURL: jumpSound, error: nil)
		jumpSoundPlayer.prepareToPlay()
		jumpSoundPlayer.volume = 0.5

		dieSoundPlayer = AVAudioPlayer(contentsOfURL: dieSound, error: nil)
		dieSoundPlayer.prepareToPlay()

		introSoundPlayer = AVAudioPlayer(contentsOfURL: introSound, error: nil)
		introSoundPlayer.prepareToPlay()
		introSoundPlayer.numberOfLoops = -1

		scoreSoundPlayer = AVAudioPlayer(contentsOfURL: scoreSound, error: nil)
		scoreSoundPlayer.prepareToPlay()

		pigWalkingTextureArray = [imageCache["pigwalk1"] as SKTexture!
								, imageCache["pigwalk2"] as SKTexture!
								, imageCache["pigwalk3"] as SKTexture!
								, imageCache["pigwalk2"] as SKTexture!]

		pigJumpingTextureArray = [imageCache["pigjump"] as SKTexture!]

		pigFlyingTextureArray = [imageCache["pigfly1"] as SKTexture!
								, imageCache["pigfly2"] as SKTexture!]

		appleTextureArray = [imageCache["apple1"] as SKTexture!
							, imageCache["apple2"] as SKTexture!
							, imageCache["apple3"] as SKTexture!
							, imageCache["apple4"] as SKTexture!]

		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			self.authenticateLocalPlayer()
		})

	}

	func authenticateLocalPlayer() {

		localPlayer.authenticateHandler =
			{ (viewController : UIViewController!, error : NSError!) -> Void in
				if viewController != nil {
					self.view?.window?.rootViewController?.presentViewController(viewController, animated:true, completion: nil)
				} else {
					if self.localPlayer.authenticated {
						self.gameCenterEnabled = true
						self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler
							{ (leaderboardIdentifier, error) -> Void in
								if error != nil {
									print("error")
								} else {
									self.leaderboardIdentifier = leaderboardIdentifier
									self.syncPlayerScore()
								}
						}
					} else {
						println("not able to authenticate fail")
						self.gameCenterEnabled = false

						if (error != nil) {
							println("\(error.description)")
						} else {
							println("error is nil")
						}
					}
				}
		}
	}

	func syncPlayerScore () {

		if GKLocalPlayer.localPlayer().authenticated {

			self.leaderBoard.identifier = leaderboardIdentifier

			leaderBoard.loadScoresWithCompletionHandler { (scores:[AnyObject]!, error:NSError!) -> Void in

				if error != nil {

					println("error loading scores")
					println(error)

				} else {

					var highScore:Int? = self.keyStore.objectForKey("highScore") as? Int

					if highScore != nil && (self.leaderBoard.localPlayerScore == nil || Int64(highScore!) > self.leaderBoard.localPlayerScore.value) {

						let gkScore = GKScore(leaderboardIdentifier: self.leaderboardIdentifier)

						gkScore.value = Int64(highScore!)

						GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError!) -> Void in
							if (error != nil) {
								// handle error
								println("Error: " + error.localizedDescription);
							}
						}))

					} else if (highScore == nil && self.leaderBoard.localPlayerScore != nil) || (highScore != nil && self.leaderBoard.localPlayerScore != nil && Int64(highScore!) < self.leaderBoard.localPlayerScore.value) {

						self.keyStore.setObject(Int(self.leaderBoard.localPlayerScore.value), forKey: "highScore")

						if self.scene?.speed == 0 {
							self.scoreLabel.text = "High Score: \(self.leaderBoard.localPlayerScore.value)"
						}
						
					}
					
				}
				
			}
			
		}
		
	}

	func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
		gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
	}

	func showLeaderboard()
	{
		var gcViewController: GKGameCenterViewController = GKGameCenterViewController()
		gcViewController.gameCenterDelegate = self

		gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
		gcViewController.leaderboardIdentifier = leaderboardIdentifier

		self.view?.window?.rootViewController?.presentViewController(gcViewController, animated: true, completion: nil)

		GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "show_leaderboard",label:"leaderboard",value:nil).build() as [NSObject : AnyObject])

	}

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */

		for touch: AnyObject in touches {

			let location = touch.locationInNode(self)
			let touchedNode = nodeAtPoint(location);

			if touchedNode.name == "leaderboardButton" {

				self.showLeaderboard()

			} else if touchedNode.name == "startButton" {

				if !gameOver && gamePlaying && scene?.speed == 0 {

					NSNotificationCenter.defaultCenter().postNotificationName("hideAdBanner", object: nil)

					introSoundPlayer.stop()
					introSoundPlayer.currentTime = 0

					bgSoundPlayer = AVAudioPlayer(contentsOfURL: bgSound, error: nil)
					bgSoundPlayer.prepareToPlay()
					bgSoundPlayer.numberOfLoops = -1
					bgSoundPlayer.play()

					playerAnim("walk")

					scoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame) - 100.0)
					scoreLabel.fontSize = 65
					scoreLabel.text = "0"
					scene?.speed = 1

					leaderboardBtn.removeFromParent()
					startBtn.removeFromParent()
				}

			} else {

				if !gameOver && canJump {

					if !canFly {
						canJump = false
					}

					doJump()
				}
				
				if !gameOver {
					continueJump = true
				}

			}

		}
    }

	func playerAnim(animType:NSString) {


		if animType == "walk" && currentAnim != "walk" {

			player.removeActionForKey("playerJump")
			player.removeActionForKey("playerFall")
			player.removeActionForKey("playerSit")
			player.removeActionForKey("playerRun")

			let walkAnim = SKAction.animateWithTextures(pigWalkingTextureArray as [AnyObject], timePerFrame: 0.1)
			let walkRepeatAnim = SKAction.repeatActionForever(walkAnim)
			player.runAction(walkRepeatAnim, withKey: "playerWalk")

		} else if animType == "jump" && currentAnim != "jump" {

			player.removeActionForKey("playerWalk")
			player.removeActionForKey("playerFall")
			player.removeActionForKey("playerSit")
			player.removeActionForKey("playerRun")

			var tmpTexture:NSMutableArray

			if canFly {
				tmpTexture = pigFlyingTextureArray
			} else {
				tmpTexture = pigJumpingTextureArray
			}

			let jumpAnim = SKAction.animateWithTextures(tmpTexture as [AnyObject], timePerFrame: 0.2)

			let jumpRepeatAnim = SKAction.repeatActionForever(jumpAnim)
			player.runAction(jumpRepeatAnim, withKey: "playerJump")

		}

		currentAnim = animType

	}

	func playerScore(points:Int) {

		score += points

		scoreSoundPlayer.stop()
		scoreSoundPlayer.currentTime = 0.0
		scoreSoundPlayer.play()

		scoreLabel.text = String(score)

	}
    
    func doJump() {

		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			self.jumpSoundPlayer.stop()
			self.jumpSoundPlayer.currentTime = 0.0
			self.jumpSoundPlayer.play()
		})

        playerAnim("jump")

		player.physicsBody?.velocity = CGVectorMake(0, 0)
        player.physicsBody?.applyImpulse(CGVectorMake(0, 150))

	}
    
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        continueJump = false
    }
   
    override func update(currentTime: CFTimeInterval) {

		if !gameOver && player.frame.minY < 0 {

			playerDie();

		} else if scene?.speed != 0 {

			if platforms.children.count > 0 {

				var tmpPoint:CGPoint

				for (index, tmpNode) in enumerate(platforms.children) {

					tmpPoint = self.convertPoint(tmpNode.frame.origin, fromNode: tmpNode as! SKNode)

					if tmpPoint.x < (0 - tmpNode.frame.width) {
						tmpNode.removeFromParent()
					}
					
				}

				var tmpLastNodeChild:SKNode

				if lastNode.children.count > 0 {
					tmpLastNodeChild = lastNode.children.last as! SKNode
				} else {
					tmpLastNodeChild = lastNode
				}

				let lastPoint:CGPoint = self.convertPoint(tmpLastNodeChild.frame.origin, fromNode: tmpLastNodeChild)

				if (lastPoint.x - tmpLastNodeChild.frame.width) <= outsideWidth {
					drawPlatforms()
				}

			}

			if player.frame.maxY >= selfFrame.height {
				player.physicsBody?.velocity = CGVectorMake(0, 0)
			}

		}

		if canRestart {
			scene?.speed = 0
			canRestart = false
			resetGame()
		}

    }

	func didEndContact(contact: SKPhysicsContact) {
		if !gameOver && gamePlaying && player.position.x != playerX {
			player.runAction(SKAction.moveToX(playerX, duration: 1))
		}
	}

    func didBeginContact(contact: SKPhysicsContact) {

        var contactA:SKPhysicsBody = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyA : contact.bodyB
        var contactB:SKPhysicsBody = contact.bodyB.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyB : contact.bodyA
        
        var bA:SKNode = contactA.node!
        var bB:SKNode = contactB.node!

		if contactB.categoryBitMask == platformTopCategory {
            
            playerDie()

		} else if contactB.categoryBitMask == platformScoreCategory {

			if bB.alpha == 1.0 {

				dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
					self.playerScore(1)
				})

				bB.runAction(SKAction.moveToY(bB.frame.origin.y + 80, duration: NSTimeInterval(0.5)))
				bB.runAction(SKAction.fadeOutWithDuration(NSTimeInterval(0.5)))

			}

		} else if contactB.categoryBitMask == platformBottomCategory {

			if ( floor(contact.contactPoint.y) > ceil(bA.frame.minY) + 2 ) &&  (floor(contact.contactPoint.x) > ceil(bA.frame.midX)) {

				playerDie()

			}

		} else if contactB.categoryBitMask == platformTrapCategory {

			playerDie()

		} else if contactB.categoryBitMask == platformBadPickupCategory {

			playerDie()

		}

		if contactB.categoryBitMask != platformScoreCategory {
			if continueJump {
				doJump()
			} else {
				canJump = true
				playerAnim("walk")
			}
		}
    }

	func playerDie() {

		var highScore:Int? = keyStore.objectForKey("highScore") as? Int

		if highScore == nil || highScore! < score {
			keyStore.setObject(score, forKey: "highScore")
		}

		syncPlayerScore()

        gameOver = true
		canJump = false
		continueJump = false
		gamePlaying = false

		if player.frame.minY < 0 {
			player.position.y = ((outsideHeight/2) + (player.frame.height) / 2)
		}

        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = 0
        player.physicsBody?.velocity = CGVectorMake(0, 0)
        player.physicsBody?.applyImpulse(CGVectorMake(50, 100))
        
        self.removeActionForKey("flash")

		platforms.removeActionForKey("platformMove")

		self.runAction(SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({
            self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }),SKAction.waitForDuration(NSTimeInterval(0.001)), SKAction.runBlock({
            self.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.9, alpha: 1.0)
        }), SKAction.waitForDuration(NSTimeInterval(3))]), count:1), SKAction.runBlock({

			var tmpNode:SKNode!
			var tmpSubNode:SKNode!

			for (index, tmpNode) in enumerate(self.platforms.children) {
				for (index, tmpSubNode) in enumerate(tmpNode.children) {
					tmpSubNode.runAction(SKAction.removeFromParent())
				}
				tmpNode.runAction(SKAction.removeFromParent())
			}

			self.canRestart = true

        })]), withKey: "flash")

		bgSoundPlayer.stop()
		bgSoundPlayer.currentTime = 0.0

		dieSoundPlayer.stop()
		dieSoundPlayer.currentTime = 0.0
		dieSoundPlayer.play()

		AudioServicesPlaySystemSound(vibrateSound)

    }
    
    func animatePlatforms() {

		platforms.runAction(
			SKAction.sequence([
				SKAction.moveByX(-1000, y:0.0, duration:NSTimeInterval(playerSpeed)),
				SKAction.runBlock({

					self.animatePlatforms()

						})]), withKey: "platformMove")
	}

	func drawPlatforms() {

		var currentMap:Dictionary = getLevelMap(currentLevel)

		level_hasTop = currentMap["hasTop"] as? Int
		level_hasBottom = currentMap["hasBottom"] as? Int
		level_touchTop = currentMap["touchTop"] as? Int
		level_touchBottom = currentMap["touchBottom"] as? Int
		level_platformGap = currentMap["platformGap"] as? Int
		level_platformCount = currentMap["platformCount"] as? Int
		level_preserveHeight = currentMap["preserveHeight"] as? Int
		level_offsetTop = currentMap["offsetTop"] as? Int
		level_offsetBottom = currentMap["offsetBottom"] as? Int
		level_badPickupRate = currentMap["badPickupRate"] as? Int
		level_mobRate = currentMap["mobRate"] as? Int
		level_platformImage = currentMap["platformImage"] as? Array
		level_platformWidth = currentMap["platformWidth"] as? Int
		level_platformHasPhysics = currentMap["platformHasPhysics"] as? Int
		level_hasPickups = currentMap["hasPickups"] as? Int

		levelSteps = currentMap["platformCount"] as? Int

		let platformPair = SKNode()
		let platformWidth:CGFloat = CGFloat(level_platformWidth!)

		var platformSpacer:CGFloat = 0
		//let lastNode:SKNode = platforms.children.last as SKNode

		var xPoint:CGFloat = 0

		var platformY:CGFloat = 0

		if levelPlatformPosition == 0 {

			if level_offsetTop == nil {
				platformY = 0 + (outsideHeight/2) - ( floor(CGFloat((arc4random_uniform(UInt32(outsideHeight/2))))) + 25)
			} else {
				platformY = (outsideHeight/2) + CGFloat(level_offsetTop!)
			}

			if level_offsetBottom == nil {
				platformSpacer = CGFloat( ( 200 - ( score * 2 ) ) > 100 ? ( 200 - ( score * 2 ) ) : 100 )
			} else {
				platformSpacer = (outsideHeight/2) + CGFloat(level_offsetBottom!)
			}

			levelPreviousSpacer = platformSpacer
			levelPreviousHeight = platformY

			if level_platformGap != nil {
				xPoint += CGFloat(level_platformGap!)
			}

		} else {

			platformY = levelPreviousHeight

			platformSpacer = levelPreviousSpacer

		}

		// TOP PLATFORM

		var platformTextureArray:Array<SKTexture> = Array()
		var platformAnim = SKAction()
		var platformRepeatAnim = SKAction()

		var end = (level_platformImage?.count)
		var x = 0

		if level_platformImage?.count > 1 {

			for x in 1...Int(end!) {

				var tmpString:String? = level_platformImage?[x-1]
				platformTextureArray.append(imageCache[tmpString!] as SKTexture!)

			}

			platformAnim = SKAction.animateWithTextures(platformTextureArray, timePerFrame: 0.1)
			platformRepeatAnim = SKAction.repeatActionForever(platformAnim)

		}

		if level_hasTop == 1 {

			let platformTop = SKSpriteNode(imageNamed: level_platformImage?.first! as String!)

			if level_platformImage?.count > 1 {
				platformTop.runAction(platformRepeatAnim, withKey: "platformRepeat")
			}

			platformTop.setScale(1)

			if level_platformHasPhysics == 1 {

				platformTop.physicsBody = SKPhysicsBody(rectangleOfSize: platformTop.size)
				platformTop.physicsBody?.dynamic = false
				platformTop.physicsBody?.allowsRotation = false
				platformTop.physicsBody?.categoryBitMask = platformTopCategory
				platformTop.physicsBody?.collisionBitMask = groundCategory | platformTopCategory
				platformTop.physicsBody?.contactTestBitMask = groundCategory | platformTopCategory
				platformTop.physicsBody?.usesPreciseCollisionDetection = false
				platformTop.physicsBody?.restitution = 0.0

			}

			platformTop.position = CGPointMake(0, (platformY + (platformTop.frame.height / 2)))

			platformPair.addChild(platformTop)

		}

		// BOTTOM PLATFORM

		let platformBottom = SKSpriteNode(imageNamed: level_platformImage?.first! as String!)

		if level_platformImage?.count > 1 {
			platformBottom.runAction(platformRepeatAnim, withKey: "platformRepeat")
		}

		platformBottom.setScale(1)

		if level_platformHasPhysics == 1 {

			platformBottom.physicsBody = SKPhysicsBody(rectangleOfSize: platformBottom.size)
			platformBottom.physicsBody?.dynamic = false
			platformBottom.physicsBody?.allowsRotation = false

			if level_touchBottom == 1 {
				platformBottom.physicsBody?.categoryBitMask = platformBottomCategory
				platformBottom.physicsBody?.collisionBitMask = groundCategory | platformBottomCategory
				platformBottom.physicsBody?.contactTestBitMask = groundCategory | platformBottomCategory
			} else {
				platformBottom.physicsBody?.categoryBitMask = platformTrapCategory
				platformBottom.physicsBody?.collisionBitMask = groundCategory | platformTrapCategory
				platformBottom.physicsBody?.contactTestBitMask = groundCategory | platformTrapCategory
			}

			platformBottom.physicsBody?.usesPreciseCollisionDetection = true
			platformBottom.physicsBody?.restitution = 0.0

		}

		platformBottom.position = CGPointMake(0, (platformY - CGFloat(platformSpacer) - (platformBottom.frame.height / 2)))

		platformPair.addChild(platformBottom)

		// SCORE NODE

		if level_hasPickups == 1 && ( currentLevel > 0 || levelPosition > 2 ) {

			var tmpNum = floor(CGFloat(arc4random_uniform(UInt32(level_badPickupRate!) + UInt32(1))))
			var isBadPickup:Bool = ( tmpNum == 1 ? true : false )

			var platformScore:SKSpriteNode

			if isBadPickup {
				platformScore = SKSpriteNode(imageNamed: "barrel")
				platformScore.position = CGPointMake(0 , (platformBottom.frame.maxY + (platformScore.frame.height / 2)))
			} else {
				platformScore = SKSpriteNode(imageNamed: "apple1")
				platformScore.position = CGPointMake(0 , (platformBottom.frame.maxY + ( platformScore.frame.height / 2) + 10))
			}

			platformScore.setScale(1)

			platformScore.physicsBody = SKPhysicsBody(rectangleOfSize: platformScore.size)
			platformScore.physicsBody?.dynamic = false
			platformScore.physicsBody?.allowsRotation = false
			platformScore.physicsBody?.usesPreciseCollisionDetection = false
			platformScore.physicsBody?.restitution = 0.0

			if isBadPickup {
				platformScore.physicsBody?.categoryBitMask = platformBadPickupCategory
				platformScore.physicsBody?.collisionBitMask = platformBadPickupCategory
				platformScore.physicsBody?.contactTestBitMask = platformBadPickupCategory
			} else {
				platformScore.physicsBody?.categoryBitMask = platformScoreCategory
				platformScore.physicsBody?.collisionBitMask = platformScoreCategory
				platformScore.physicsBody?.contactTestBitMask = platformScoreCategory
			}



			platformPair.addChild(platformScore)

		}

		// POSITION AND RUN

		platforms.addChild(platformPair)

		xPoint -= (platformWidth/2)

		if lastNode != nil {
			xPoint += (lastNode.calculateAccumulatedFrame().origin.x + lastNode.calculateAccumulatedFrame().width)
			//xPoint = (lastNode.frame.origin.x) + (platformWidth / 2)
		}


		platformPair.position = CGPointMake((xPoint + CGFloat(level_platformWidth!)), zeroPoint)

		lastNode = platformPair


		// SET THE LEVEL MAP

		levelPosition++
		levelPlatformPosition++

		if levelPlatformPosition == level_preserveHeight {
			levelPlatformPosition = 0
		}

		if levelPosition >= levelSteps {

			if currentMap["nextLevel"] as? Int != nil {
				currentLevel = currentMap["nextLevel"] as! Int!
			} else {
				currentLevel++
			}


			levelPlatformPosition = 0
			levelPreviousHeight = 0
			levelPosition = 0
		}
        
    }
    
    func resetGame() {

		NSNotificationCenter.defaultCenter().postNotificationName("showAdBanner", object: nil)

		keyStore.synchronize()
		var highScore:Int? = keyStore.objectForKey("highScore") as? Int

		lastNode = nil
		currentLevel = 0
		levelPosition = 0
		levelPlatformPosition = 0
		levelPreviousHeight = 0

		//self.scene.showAd()

		removeAllChildren()
		scene?.removeAllChildren()

		scoreLabel.text = ""

		if highScore != nil && highScore! > 0 {
			scoreLabel.text = "High Score: \(highScore!)"
		}

		scoreLabel.fontSize = 30
		scoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame) - 100.0)

		self.addChild(scoreLabel)

		scoreLabel.zPosition = 100

		player.setScale(2.0)
		player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
		player.physicsBody?.dynamic = true
		player.physicsBody?.allowsRotation = false
		player.physicsBody?.categoryBitMask = playerCategory
		player.physicsBody?.collisionBitMask = groundCategory | platformTopCategory | platformBottomCategory | platformTrapCategory | platformCategory
		player.physicsBody?.contactTestBitMask = groundCategory | platformTopCategory | platformBottomCategory | platformTrapCategory | platformCategory | platformScoreCategory | platformBadPickupCategory | platformMobCategory
		player.physicsBody?.usesPreciseCollisionDetection = true
		player.physicsBody?.restitution = 0.0
		player.name = "player"

		self.addChild(player)

		player.zPosition = 10

		self.addChild(platforms)

		platforms.position = CGPoint(x: 0.0 , y: 0.0)

        canJump = true
        playerSpeed = 3.5

		if outsideWidth > 500 {
			playerFixLeft = 150
		} else {
			playerFixLeft = 100
		}
        
        player.xScale = 1
        player.yScale = 1
        player.position = CGPoint(x:CGFloat(playerFixLeft), y:((outsideHeight/2) + (player.frame.height) / 2))

        playerX = player.position.x

		drawPlatforms()

		while (self.convertPoint(lastNode.frame.origin, fromNode: lastNode).x / 2) < outsideWidth {
			drawPlatforms()
		}

		animatePlatforms()

		gameOver = false
		gamePlaying = true

		score = 0

		leaderboardBtn.position = CGPoint(x:((outsideWidth/2)), y:80.0)
		leaderboardBtn.zPosition = 1000
		leaderboardBtn.userInteractionEnabled = false
		leaderboardBtn.name = "leaderboardButton"

		self.addChild(leaderboardBtn)

		startBtn.position = CGPoint(x:((outsideWidth/2)), y:160.0)
		startBtn.zPosition = 1000
		startBtn.userInteractionEnabled = false
		startBtn.name = "startButton"

		self.addChild(startBtn)

		introSoundPlayer.currentTime = 0.9
		introSoundPlayer.play()
    }

	func getLevelMap(level:Int) -> Dictionary<String, Any?> {

		var map:Dictionary<String, Any?>!

		switch (level) {

			case 0:
				map = ["platformGap":0
					,"platformCount":12
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":1
					,"offsetTop":0
					,"offsetBottom":0
					,"badPickupRate":2
					,"hasPickups":1
					,"mobRate":0
					,"platformImage":["platformGrass"]
					,"platformWidth":200
					,"platformHasPhysics":1]

			case 1:
				map = ["platformGap":0
					,"platformCount":1
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":5
					,"offsetTop":-15
					,"offsetBottom":0
					,"badPickupRate":0
					,"hasPickups":0
					,"mobRate":0
					,"platformImage":["platformWater","platformWater_3","platformWater_5","platformWater_7","platformWater_9","platformWater_11"]
					,"platformWidth":160
					,"platformHasPhysics":0]

			case 2:
				map = ["platformGap":0
					,"platformCount":20
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":5
					,"offsetTop":0
					,"offsetBottom":0
					,"badPickupRate":2
					,"hasPickups":1
					,"mobRate":0
					,"platformImage":["platformGrass"]
					,"platformWidth":200
					,"platformHasPhysics":1]

			case 3:
				map = ["platformGap":0
					,"platformCount":1
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":0
					,"preserveHeight":5
					,"offsetTop":-15
					,"offsetBottom":0
					,"badPickupRate":0
					,"hasPickups":0
					,"mobRate":0
					,"platformImage":["platformWater","platformWater_3","platformWater_5","platformWater_7","platformWater_9","platformWater_11"]
					,"platformWidth":160
					,"platformHasPhysics":0]

			case 4:
				map = ["platformGap":0
					,"platformCount":30
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":1
					,"offsetTop":0
					,"offsetBottom":0
					,"badPickupRate":2
					,"hasPickups":1
					,"mobRate":0
					,"platformImage":["platformGrass"]
					,"platformWidth":200
					,"platformHasPhysics":1]

			case 5:
				map = ["platformGap":0
					,"platformCount":12
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":1
					,"offsetTop":0
					,"offsetBottom":0
					,"badPickupRate":2
					,"hasPickups":1
					,"mobRate":0
					,"platformImage":["platformGrass"]
					,"platformWidth":200
					,"platformHasPhysics":1]

			case 6:
				map = ["platformGap":0
					,"platformCount":1
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":5
					,"offsetTop":-15
					,"offsetBottom":0
					,"badPickupRate":0
					,"hasPickups":0
					,"mobRate":0
					,"platformImage":["platformWater","platformWater_3","platformWater_5","platformWater_7","platformWater_9","platformWater_11"]
					,"platformWidth":160
					,"platformHasPhysics":0]

			case 7:
				map = ["platformGap":0
					,"platformCount":20
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":5
					,"offsetTop":0
					,"offsetBottom":0
					,"badPickupRate":2
					,"hasPickups":1
					,"mobRate":0
					,"platformImage":["platformGrass"]
					,"platformWidth":200
					,"platformHasPhysics":1]

			case 8:
				map = ["platformGap":0
					,"platformCount":1
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":0
					,"preserveHeight":5
					,"offsetTop":-15
					,"offsetBottom":0
					,"badPickupRate":0
					,"hasPickups":0
					,"mobRate":0
					,"platformImage":["platformWater","platformWater_3","platformWater_5","platformWater_7","platformWater_9","platformWater_11"]
					,"platformWidth":160
					,"platformHasPhysics":0]

			case 9:
				map = ["platformGap":0
					,"platformCount":30
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":1
					,"offsetTop":0
					,"offsetBottom":0
					,"badPickupRate":2
					,"hasPickups":1
					,"mobRate":0
					,"platformImage":["platformGrass"]
					,"platformWidth":200
					,"platformHasPhysics":1]

			default:
				map = ["platformGap":170
					,"platformCount":40
					,"hasTop":0
					,"hasBottom":1
					,"touchTop":0
					,"touchBottom":1
					,"preserveHeight":5
					,"offsetTop":0
					,"offsetBottom":0
					,"badPickupRate":2
					,"hasPickups":1
					,"mobRate":0
					,"platformImage":["platformGrass"]
					,"platformWidth":200
					,"platformHasPhysics":1
					,"nextLevel":1]
			
		}

		return map

	}

}
