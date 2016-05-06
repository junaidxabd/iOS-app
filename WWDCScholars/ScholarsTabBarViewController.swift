//
//  ScholarsTabBarViewController.swift
//  WWDCScholars
//
//  Created by Sam Eckert on 09.04.16.
//  Copyright © 2016 WWDCScholars. All rights reserved.
//

import UIKit
import AVFoundation

class ScholarsTabBarViewController: UITabBarController {
    private var tapSoundEffect: AVAudioPlayer!
    private var session = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleUI()
    }
    
    // MARK: - Internal
    
    internal func segueToIntro() {
        self.performSegueWithIdentifier(String(IntroViewController), sender: nil)
    }
    
    // MARK: - UI
    
    private func styleUI() {
        self.tabBar.tintColor = UIColor.scholarsPurpleColor()
        self.tabBar.items![2].enabled = false
        
        let image = UIImage(named: "wwdcScholarsTabIcon")!
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setBackgroundImage(image, forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(ScholarsTabBarViewController.segueToIntro), forControlEvents: .TouchUpInside)
        
        let heightDifference = image.size.height - self.tabBar.frame.size.height
        
        if heightDifference < 0 {
            button.center = self.tabBar.center
        } else {
            var center = self.tabBar.center
            center.y = center.y - heightDifference / 2
            button.center = center
        }
        
        self.view.addSubview(button)
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        do {
           try session.setCategory(AVAudioSessionCategoryAmbient)
        } catch {
            print("Failed setting category")
        }
        
        let path = NSBundle.mainBundle().pathForResource("tabBarDidSelectItem.m4a", ofType: nil)!
        let url = NSURL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            tapSoundEffect = sound
            tapSoundEffect.volume = 0.01
            sound.play()
        } catch {
            print("Failed to load tab bar sound file")
        }
    }
}
