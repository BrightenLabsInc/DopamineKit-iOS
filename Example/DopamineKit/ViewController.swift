//
//  ViewController.swift
//  DopamineKit
//
//  Created by Akash Desai on 07/13/2016.
//  Copyright (c) 2016 Akash Desai. All rights reserved.
//

import UIKit
import DopamineKit

class ViewController: UIViewController {
    
    func action1Performed(){
        // Reinforce the action to make it sticky!!
        DopamineKit.reinforce("action1", metaData: ["key":"value"], completion: {
            reinforcement in
                
                // Update UI to display reinforcement decision on screen for learning purposes
                self.responseLabel.text = reinforcement
                self.flash(self.responseLabel)
            
                // Now you should use `response` to call a reward function paired on the Dopamine Developer Dashboard
            
            
                // Try out CandyBar as a form of reinforcement!
                // The functions paired here are medaltStar, stars, and thumbsUp
                var reinforcerType:CandyIcon
                var title:String?
                var subtitle:String?
                var backgroundColor:UIColor = UIColor.blueColor()
                var visibilityDuration:NSTimeInterval = 1.75
                
                // Set up a couple of different responses to keep your users surprised
                switch(reinforcement){
                case "medalStar":
                    reinforcerType = CandyIcon.MedalStar
                    title = "You should drop an album soon"
                    subtitle = "Cuz you're on 🔥"
                    break
                case "stars":
                    reinforcerType = CandyIcon.Stars
                    title = "Great workout 💯"
                    subtitle = "It's not called sweating, it's called glisenting"
                    backgroundColor = UIColor.orangeColor()
                    break
                case "thumbsUp":
                    reinforcerType = CandyIcon.ThumbsUp
                    title = "Awesome run!"
                    subtitle = "Either you run the day,\nOr the day runs you."
                    backgroundColor = CandyBar.hexStringToUIColor("#ff0000")
                    visibilityDuration = 2.5
                    break
                default:
                    return
                }
                
                // Woo hoo! Treat yoself
                let candybar = CandyBar(title: title, subtitle: subtitle, icon: reinforcerType, backgroundColor: backgroundColor)
                // if `nil` or no duration is provided, the CandyBar will go away when the user taps it or `candybar.dismiss()` is used
                candybar.show(visibilityDuration)
            
        })
    }
    
    func action2Performed(){
        // Tracking call is sent asynchronously
        DopamineKit.track("action2", metaData: ["key":"value", "calories":9000])
    }
    
    
    
    
    ///////////////////////////////////////
    //
    //  UI Setup
    //
    ///////////////////////////////////////
    
    var responseLabel:UILabel = UILabel()
    var action1Button:UIButton = UIButton()
    var trackedActionButton:UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBasicUI()
        let _ = DopamineKit.sharedInstance
    }
    
    func loadBasicUI(){
        let viewSize = self.view.frame.size
        let viewCenter = self.view.center
        
        // Dopamine icon up top
        let dopamineIcon = UIImage(named:"DopamineLogo")
        
        let imageView = UIImageView(image: dopamineIcon)
        imageView.center = CGPointMake(viewSize.width/2, 100)
        self.view.addSubview(imageView)
        
        // Response label below dopamine icon
        responseLabel = UILabel.init(frame: CGRectMake(0, 150, viewSize.width, 50))
        responseLabel.text = "Click a button below!"
        responseLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(responseLabel)
        
        // Button to represent some user action to Reinforce
        action1Button = UIButton.init(frame: CGRectMake(0, 0, viewSize.width/3, viewSize.width/6+10))
        action1Button.center = CGPointMake(viewSize.width/4, viewCenter.y)
        action1Button.layer.cornerRadius = 5
        action1Button.setTitle("Reinforce a user action", forState: UIControlState.Normal)
        action1Button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        action1Button.titleLabel?.textAlignment = NSTextAlignment.Center
        action1Button.backgroundColor = UIColor.init(red: 51/255.0, green: 153/255.0, blue: 51/255.0, alpha: 1.0)
        action1Button.addTarget(self, action: #selector(ViewController.action1Performed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(action1Button)
        
        // Button to represent some user action to Track
        trackedActionButton = UIButton.init(frame: CGRectMake(0, 0, viewSize.width/3, viewSize.width/6+10))
        trackedActionButton.center = CGPointMake(viewSize.width/4*3, viewCenter.y)
        trackedActionButton.layer.cornerRadius = 5
        trackedActionButton.setTitle("Track a user action", forState: UIControlState.Normal)
        trackedActionButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        trackedActionButton.titleLabel?.textAlignment = NSTextAlignment.Center
        trackedActionButton.backgroundColor = UIColor.init(red: 204/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
        trackedActionButton.addTarget(self, action: #selector(ViewController.action2Performed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(trackedActionButton)
    }
    
    func flash(elm:UIView){
        elm.alpha = 0.0
        UIView.animateWithDuration(0.75, delay: 0.0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {() -> Void in
            elm.alpha = 1.0
            }, completion: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}

