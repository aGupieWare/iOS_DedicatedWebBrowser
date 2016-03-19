//
//  ViewController.swift
//  AGW Dedicated Web Browser
//
//  Created by Stefan Agapie on 5/1/15.
//  Copyright (c) 2015 aGupieWare. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        
        // This call will ask the storyboard that is associated with this   //
        // controller to perform the segue with the given identifier        //
        self.performSegueWithIdentifier("AGWDedicatedWebViewControllerSegue", sender: self)
    }

}

