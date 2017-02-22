//
//  ViewController.swift
//  Base Tracker Umpire
//
//  Created by Jack Bruienne on 7/19/16.
//  Copyright © 2016 MCJack123. All rights reserved.
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
	@IBOutlet var swipeGesture: UISwipeGestureRecognizer!
	private func createAndAddSwipeGesture()
    {
        swipeGesture.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(swipeGesture)
    }

    @IBAction func handleSwipeLeft(recognizer:UIGestureRecognizer)
    {
        print(" Handle swipe left...")

    }
}

