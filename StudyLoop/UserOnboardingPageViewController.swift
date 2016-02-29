//
//  UserOnboardingPageViewController.swift
//  StudyLoop
//
//  Created by Chris Martin on 2/19/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

protocol UserOnboardingDelegate {
    /**
     Moves the PageViewController forwards by one
    - returns: True if successful, false if otherwise
    */
    func advanceByOne() -> Bool
    /**
     Moves the PageViewController backwards by one
     - returns: True if successful, false if otherwise
     */
    func receedByOne() -> Bool
    /**
     Signifies the current index of the PageViewController
     */
    var pageIndex: Int! { get set }
}

class UserOnboardingPageViewController: UIPageViewController, UserOnboardingDelegate {
    
    var player: AVPlayer?
    var currentViewController: UIViewController!
    var overlayViewController: UIOverlayViewController!
    var blurView: UIVisualEffectView!
    var pageIndex: Int! = 0 {
        didSet {
            print(pageIndex)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        dataSource = self
        
        let blurEffect = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.alpha = 0
        self.view.insertSubview(blurView, atIndex: 0)
        
        self.overlayViewController = initializeOverlayView()
        self.view.addSubview(self.overlayViewController.view)
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
            self.currentViewController = firstViewController
        }
        
        let playerLayer = createVideoBackgroundLayer()
        let overlayLayer = createOverlayLayer()
        print(playerLayer)
        if playerLayer != nil {
            self.view.layer.insertSublayer(overlayLayer, atIndex: 0)
            self.view.layer.insertSublayer(playerLayer!, atIndex: 0)
            player?.play()
        }
    }
    
    func loopVideo() {
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }
    
    func createOverlayLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = SL_GREEN.blendColor(UIColor.blackColor(), amount: 0.75).CGColor
        layer.opacity = 0.5
        layer.frame = self.view.bounds
        return layer
    }
    
    func createVideoBackgroundLayer() -> AVPlayerLayer? {
        // Error Checking
        guard let videoURL: NSURL = NSBundle.mainBundle().URLForResource("minkao", withExtension: "mp4") else {
            print("Loading of video failed")
            return nil
        }
        
        guard let player: AVPlayer = AVPlayer(URL: videoURL) else {
            print("Player URL didn't take")
            return nil
        }
        
        // Video Config
        player.actionAtItemEnd = .None
        player.muted = true
        
        // Layer creation
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = self.view.bounds
        
        //loop video
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "loopVideo",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        
        // Player delegate
        self.player = player
        return playerLayer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(VIEW_CONTROLLER_HOME),
                self.newViewController("OneViewController"),
                self.newViewController("TwoViewController")]
    }()
    
    private func newViewController(vc: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier(vc)
    }
    
    func initializeOverlayView() -> UIOverlayViewController? {
        guard let overlayVC = newViewController("UIOverlayController") as? UIOverlayViewController else {
            return nil
        }
        
        overlayVC.delegate = self
        overlayVC.view.frame = self.view.bounds
        return overlayVC
    }
    
    func advanceByOne() -> Bool {
        if let viewController = pageViewController(self, viewControllerAfterViewController: self.currentViewController) {
            setViewControllers([viewController],
                direction: .Forward,
                animated: true,
                completion: nil)
            self.currentViewController = viewController
            self.pageIndex! += 1
            performTransitionOnIndexChange(self.pageIndex)
            return true
        } else {
            return false
        }
    }
    
    func receedByOne() -> Bool {
        if let viewController = pageViewController(self, viewControllerBeforeViewController: self.currentViewController) {
            setViewControllers([viewController],
                direction: .Reverse,
                animated: true,
                completion: nil)
            self.currentViewController = viewController
            self.pageIndex! -= 1
            performTransitionOnIndexChange(self.pageIndex)
            return true
        } else {
            return false
        }
    }
    
    func performTransitionOnIndexChange(index: Int) {
        switch index {
        case 0:
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                if self.blurView.alpha != 0 {
                    self.blurView.alpha = 0
                }
            })
        default:
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                if self.blurView.alpha != 1 {
                    self.blurView.alpha = 1
                }
            })
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
