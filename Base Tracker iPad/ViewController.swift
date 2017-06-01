//
//  ViewController.swift
//  Base Tracker iPad
//
//  Created by Jack Bruienne on 7/19/16.
//  Copyright © 2016 MCJack123. All rights reserved.
//

import UIKit

/*class ContainerView : UIViewController {
	@IBOutlet var PageIcon: UIPageControl!
}*/

class MyPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self

        let page1: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Page1ID")
        let page2: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Page2ID")
		let page3: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Page3ID")
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        setViewControllers([page1], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
		if (currentIndex == 0) {
			print("End page 1")
			return pages[currentIndex]
		}
        let previousIndex = abs((currentIndex - 1) % pages.count)
		//myPageControl.currentPage = previousIndex
		return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
		if (currentIndex == 2) {
			print("End page 2")
			return pages[currentIndex]
		}
        let nextIndex = abs((currentIndex + 1) % pages.count)
		//myPageControl.currentPage = nextIndex
		return pages[nextIndex]
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
	
}

// Score keeper portion

class OverViewController : UIViewController {
	var home_scores = [Int]()
	var away_scores = [Int]()
	var player_list = [String]()
	var inning = 1
	var topInning = true
	var Strikes = 0
	var balls = 0
	var outs = 0
	var playerid = 0
	
	//Outlets for most variable text
	@IBOutlet var batter: UILabel!
	@IBOutlet var selector: UISegmentedControl!
	@IBOutlet var strikesText: UILabel!
	@IBOutlet var ballsText: UILabel!
	@IBOutlet var outsText: UILabel!
    
	
	/*@IBOutlet var away1st: UILabel!
	@IBOutlet var away2nd: UILabel!
	@IBOutlet var away3rd: UILabel!
	@IBOutlet var away4th: UILabel!
	@IBOutlet var away5th: UILabel!
	@IBOutlet var away6th: UILabel!
	@IBOutlet var away7th: UILabel!
	@IBOutlet var away8th: UILabel!
	@IBOutlet var away9th: UILabel!
	
	@IBOutlet var home1st: UILabel!
	@IBOutlet var home2nd: UILabel!
	@IBOutlet var home3rd: UILabel!
	@IBOutlet var home4th: UILabel!
	@IBOutlet var home5th: UILabel!
	@IBOutlet var home6th: UILabel!
	@IBOutlet var home7th: UILabel!
	@IBOutlet var home8th: UILabel!
	@IBOutlet var home9th: UILabel!
	
	func displayScores() {
		away1st.text = String(away_scores[0])
		away2nd.text = String(away_scores[1])
		away3rd.text = String(away_scores[2])
		away4th.text = String(away_scores[3])
		away5th.text = String(away_scores[4])
		away6th.text = String(away_scores[5])
		away7th.text = String(away_scores[6])
		away8th.text = String(away_scores[7])
		away9th.text = String(away_scores[8])
		
		home1st.text = String(home_scores[0])
		home2nd.text = String(home_scores[1])
		home3rd.text = String(home_scores[2])
		home4th.text = String(home_scores[3])
		home5th.text = String(home_scores[4])
		home6th.text = String(home_scores[5])
		home7th.text = String(home_scores[6])
		home8th.text = String(home_scores[7])
		home9th.text = String(home_scores[8])
	}*/
	
	@IBAction func addItem(_ sender: Any) {
	
	}
	
	@IBAction func reset(_ sender: Any) {
		home_scores = [0, 0, 0, 0, 0, 0, 0, 0, 0]
		away_scores = [0, 0, 0, 0, 0, 0, 0, 0, 0]
		inning = 1
		topInning = true
		Strikes = 0
		balls = 0
		outs = 0
		playerid = 0
		//displayScores()
	}
}
