//
//  GameViewController.swift
//  FarmRun
//
//  Created by Ricardo Russon on 10/11/2014.
//  Copyright (c) 2014 BuzzCloud. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {

	var adB:GADBannerView!

	override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        scene.size = skView.bounds.size
        skView.presentScene(scene)
        skView.showsPhysics = false

		

		adB = GADBannerView(adSize: GADAdSizeFullWidthPortraitWithHeight(50), origin: CGPointMake(0.0,0.0))
		adB.hidden = true
		adB.adUnitID = "ca-app-pub-0000000000000000/0000000000"
		adB.delegate = self // ??
		adB.rootViewController = self // ??
		view.addSubview(adB) // ??
		var request = GADRequest() // create request
		request.testDevices = [ GAD_SIMULATOR_ID ]; // set it to "test" request
		adB.loadRequest(request) // actually load it (?)


		NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAd:", name: "showAdBanner", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideAd:", name: "hideAdBanner", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLeaderboard:", name: "showLeaderboard", object: nil)

    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        //return Int(UIInterfaceOrientationMask.Landscape.rawValue)
		return Int(UIInterfaceOrientationMask.Portrait.rawValue) | Int(UIInterfaceOrientationMask.PortraitUpsideDown.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

	func showAd(notification: NSNotification) {
		adB.hidden = false
	}

	func hideAd(notification: NSNotification) {
		adB.hidden = true
	}

	func showLeaderboard(notification: NSNotification) {
		adB.hidden = true
	}

}
