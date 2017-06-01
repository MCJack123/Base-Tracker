//
//  ViewController.swift
//  Base Tracker iPhone
//
//  Created by Jack Bruienne on 7/19/16.
//  Copyright © 2016 MCJack123. All rights reserved.
//

import UIKit

var strikes = 0
var balls = 0
var outs = 0
var inntop = true
var inning = 1
var playerid = 0
var players = ["Jack", "Tushar", "Thor", "Elliot", "Aidan", "Daniel", "John", "Robert"]
var oppteamNumber = 7
var bases = [-1, -1, -1]
var lastBases = bases
var homeScore = 0
var awayScore = 0
var oppteamid = -1
var checkCustomSave = [false, false]

func incWithMax(variable: Int, max: Int, min: Int = 0) -> Int {
	if (variable + 1 > max) {
		return min
	}
	else {
		return variable + 1
	}
}

class PlayerViewer: UIViewController {

	@IBOutlet var PlayerTable: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

class OverviewViewer: UIViewController {

	//@IBOutlet var navigationBar: UINavigationBar!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		//navigationBar.clipsToBounds = true;
		updateText()
		//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), shareButton], animated: false)
        
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    func notSupported() {
        let alert = UIAlertController(title: "Unimplemented!", message: "This feature is not supported in this version of Base Tracker.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: updateText)
    }
	
	@IBOutlet var batSelector: UISegmentedControl!
	@IBOutlet var strikesText: UILabel!
	@IBOutlet var ballsText: UILabel!
	@IBOutlet var outsText: UILabel!
	@IBOutlet var batter: UILabel!
	@IBOutlet var runner1: UILabel!
	@IBOutlet var runner2: UILabel!
	@IBOutlet var runner3: UILabel!
	@IBOutlet var tbText: UILabel!
	@IBOutlet var inningText: UILabel!
	@IBOutlet var awayScoreText: UILabel!
	@IBOutlet var homeScoreText: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
	
	@IBAction func updateButton(_ sender: Any) {
		updateText()
	}
	func updateText() {
		if (strikes > 2) {
			strikes = 0
			balls = 0
			outs += 1
			playerid = incWithMax(variable: playerid, max: players.count)
		}
		if (balls > 3) {
			balls = 0
			strikes = 0
			playerid = incWithMax(variable: playerid, max: players.count)
			lastBases = bases
			if (bases[2] != -1) {
				bases[2] = -1
				if (inntop) {
					awayScore += 1
				} else {
					homeScore += 1
				}
			}
			if (bases[1] != -1) {
				bases[2] = bases[1]
				bases[1] = -1
			}
			if (bases[0] != -1) {
				bases[1] = bases[0]
				bases[0] = -1
			}
			bases[0] = playerid - 1
		}
		if (outs > 2) {
			outs = 0
			if (!inntop) {
				inning += 1
			}
			inntop = !inntop
			let oppt2 = oppteamid
			oppteamid = playerid
			playerid = oppt2 + 1
			strikes = 0
			balls = 0
			bases = [-1, -1, -1]
		}
		if (inning > 9) {
			inning = 1
			inntop = true
		}
		strikesText.text = String(strikes)
		ballsText.text = String(balls)
		outsText.text = String(outs)
		awayScoreText.text = String(awayScore)
		homeScoreText.text = String(homeScore)
		switch inning {
			case 1:
				inningText.text = "1st"
			case 2:
				inningText.text = "2nd"
			case 3:
				inningText.text = "3rd"
			case 4:
				inningText.text = "4th"
			case 5:
				inningText.text = "5th"
			case 6:
				inningText.text = "6th"
			case 7:
				inningText.text = "7th"
			case 8:
				inningText.text = "8th"
			case 9:
				inningText.text = "9th"
			default:
				NSLog("Why is the inning incorrect?")
		}
		if (!inntop) {
			batter.text = players[playerid]
			runner1.text = bases[0] > -1 ? players[bases[0]] : " "
			runner2.text = bases[1] > -1 ? players[bases[1]] : " "
			runner3.text = bases[2] > -1 ? players[bases[2]] : " "
			tbText.text = "Bottom"
		} else {
			batter.text = "Player " + String(playerid + 1 )
			runner1.text = bases[0] > -1 ? "Player " + String(bases[0] + 1) : " "
			runner2.text = bases[1] > -1 ? "Player " + String(bases[1] + 1) : " "
			runner3.text = bases[2] > -1 ? "Player " + String(bases[2] + 1) : " "
			tbText.text = "Top"
		}
	}
	
	@IBAction func addBat(_ sender: Any) {
		switch batSelector.selectedSegmentIndex {
		case 0:
			strikes += 1
		case 1:
			balls += 1
		case 2:
			let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: "HitController")
			self.present(loginPageView!, animated: true, completion: updateText)
		default:
			NSLog("Help! Bat selector is not a value!")
		}
		updateText()
	}
    var shareButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(OverviewViewer.notSupported))
	
}

class GameViewer: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}

class HitController: UIViewController {
	
	var testbases = [-1, -1, -1]
	var homeRuns = 0
	var checkOuts = 0
	var beenHit = false

	override func viewDidLoad() {
		super.viewDidLoad()
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
		if (inntop) {
		    player.text = playerid > -1 ? "Player " + String(playerid + 1) : " "
			base1.text  = bases[0] > -1 ? "Player " + String(bases[0] + 1) : " "
			base2.text  = bases[1] > -1 ? "Player " + String(bases[1] + 1) : " "
			base3.text  = bases[2] > -1 ? "Player " + String(bases[2] + 1) : " "
		} else {
			player.text = playerid > -1 ? players[playerid] : " "
			base1.text  = bases[0] > -1 ? players[bases[0]] : " "
			base2.text  = bases[1] > -1 ? players[bases[1]] : " "
			base3.text  = bases[2] > -1 ? players[bases[2]] : " "
		}
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func updateText() {
		if (inntop) {
			base1.text = testbases[0] > -1 ? "Player " + String(testbases[0] + 1) : " "
			base2.text = testbases[1] > -1 ? "Player " + String(testbases[1] + 1) : " "
			base3.text = testbases[2] > -1 ? "Player " + String(testbases[2] + 1) : " "
		} else {
			base1.text = testbases[0] > -1 ? players[testbases[0]] : " "
			base2.text = testbases[1] > -1 ? players[testbases[1]] : " "
			base3.text = testbases[2] > -1 ? players[testbases[2]] : " "
		}
		runsText.text = String(homeRuns)
		outsText.text = String(checkOuts)
		beenHit = true
	}
	
	@IBOutlet var player: UILabel!
	@IBOutlet var base1: UILabel!
	@IBOutlet var base2: UILabel!
	@IBOutlet var base3: UILabel!
	@IBOutlet var runsText: UILabel!
	@IBOutlet var outsText: UILabel!
	
	@IBAction func backButton(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func save(_ sender: Any) {
		// Check
		if (!beenHit) {
			let alert = UIAlertController(title: "Field unchanged", message: "Please select a place to move the player before pressing Save.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: updateText)
			return
		}
		// Save
		bases[0] = testbases[0]
		bases[1] = testbases[1]
		bases[2] = testbases[2]
		if (inntop) {awayScore += homeRuns}
		else {homeScore += homeRuns}
		outs += checkOuts
		playerid += 1
		strikes = 0
		balls = 0
		// Exit
		let appDelegate  = UIApplication.shared.delegate as! AppDelegate
		let viewController = appDelegate.window!.rootViewController as! OverviewViewer
		viewController.updateText()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func move1st(_ sender: Any) {
		testbases[0] = playerid
		testbases[1] = bases[0]
		testbases[2] = bases[1]
		homeRuns = 0
		if (bases[2] > -1) {homeRuns += 1}
		updateText()
	}
	
	@IBAction func move2nd(_ sender: Any) {
		testbases[0] = -1
		testbases[1] = playerid
		testbases[2] = bases[0]
		homeRuns = 0
		if (bases[1] > -1) {homeRuns += 1}
		if (bases[2] > -1) {homeRuns += 1}
		updateText()
	}
	
	@IBAction func move3rd(_ sender: Any) {
		testbases[0] = -1
		testbases[1] = -1
		testbases[2] = playerid
		homeRuns = 0
		if (bases[0] > -1) {homeRuns += 1}
		if (bases[1] > -1) {homeRuns += 1}
		if (bases[2] > -1) {homeRuns += 1}
		updateText()
	}
	
	@IBAction func move4th(_ sender: Any) {
		homeRuns = 1
		if (bases[0] > -1) {homeRuns += 1}
		if (bases[1] > -1) {homeRuns += 1}
		if (bases[2] > -1) {homeRuns += 1}
		testbases[0] = -1
		testbases[1] = -1
		testbases[2] = -1
		updateText()
	}
	
	@IBAction func moveOut(_ sender: Any) {
		checkOuts = 1
		move1st(sender)
		testbases[0] = -1
		updateText()
	}
	
	@IBAction func flyOut(_ sender: Any) {
		checkOuts = 1
		testbases[0] = bases[0]
		testbases[1] = bases[1]
		testbases[2] = bases[2]
		homeRuns = 0
		updateText()
	}
	
	@IBAction func customHit(_ sender: Any) {
		let alert = UIAlertController(title: "Unimplemented!", message: "This feature is not supported in this version of Base Tracker.", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: updateText)
	}
	
}

class CustomController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
		if (inntop) {
			batterLabel.text = "Player " + String(playerid + 1)
			if (bases[0] == -1) {label1st.isHidden = true}
			else {label1st.text = "Player " + String(bases[0] + 1)}
			if (bases[1] == -1) {label2nd.isHidden = true}
			else {label2nd.text = "Player " + String(bases[1] + 1)}
			if (bases[2] == -1) {label3rd.isHidden = true}
			else {label3rd.text = "Player " + String(bases[2] + 1)}
		} else {
			batterLabel.text = players[playerid]
			if (bases[0] == -1) {label1st.isHidden = true}
			else {label1st.text = players[bases[0]]}
			if (bases[1] == -1) {label2nd.isHidden = true}
			else {label2nd.text = players[bases[1]]}
			if (bases[2] == -1) {label3rd.isHidden = true}
			else {label3rd.text = players[bases[2]]}
		}
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func backButton(_ sender: Any) {
		//let tmpController :UIViewController! = self.presentingViewController;
        self.dismiss(animated: true, completion: nil);
	}
	
	@IBOutlet var batterLabel: UILabel!
	@IBOutlet var label1st: UILabel!
	@IBOutlet var label2nd: UILabel!
	@IBOutlet var label3rd: UILabel!
	@IBOutlet var batterGesture: UIPanGestureRecognizer!
	@IBOutlet var gesture1st: UIPanGestureRecognizer!
	@IBOutlet var gesture2nd: UIPanGestureRecognizer!
	@IBOutlet var gesture3rd: UIPanGestureRecognizer!
	
	@IBAction func batterDrag(_ sender: Any) {
		let translation: CGPoint = batterGesture.translation(in: batterLabel)
		// move label
		batterLabel?.center = CGPoint(x: CGFloat((batterLabel?.center.x)! + translation.x), y: CGFloat((batterLabel?.center.y)! + translation.y))
		// reset translation
		batterGesture.setTranslation(CGPoint.zero, in: batterLabel)
	}
	@IBAction func drag1st(_ sender: Any) {
		let translation: CGPoint = gesture1st.translation(in: label1st)
		// move label
		label1st?.center = CGPoint(x: CGFloat((label1st?.center.x)! + translation.x), y: CGFloat((label1st?.center.y)! + translation.y))
		// reset translation
		gesture1st.setTranslation(CGPoint.zero, in: label1st)
	}
	@IBAction func drag2nd(_ sender: Any) {
		let translation: CGPoint = gesture2nd.translation(in: label2nd)
		// move label
		label2nd?.center = CGPoint(x: CGFloat((label2nd?.center.x)! + translation.x), y: CGFloat((label2nd?.center.y)! + translation.y))
		// reset translation
		gesture2nd.setTranslation(CGPoint.zero, in: label2nd)
	}
	@IBAction func drag3rd(_ sender: Any) {
		let translation: CGPoint = gesture3rd.translation(in: label3rd)
		// move label
		label3rd?.center = CGPoint(x: CGFloat((label3rd?.center.x)! + translation.x), y: CGFloat((label3rd?.center.y)! + translation.y))
		// reset translation
		gesture3rd.setTranslation(CGPoint.zero, in: label3rd)
	}
	
	var third = -1
	var second = -1
	var first = -1
	var runs = 0
	var outCheck = 0
	@IBAction func save(_ sender: Any) {
		third = -1
		second = -1
		first = -1
		runs = 0
		outCheck = 0
		// -1 = not set, 0 = first, 1 = second, 2 = third, 3 = home, 4 = out
		var player1pos = -1
		var player2pos = -1
		var player3pos = -1
		var player4pos = -1
		// Save
		NSLog(String(describing: batterLabel.frame.origin.x) + ", " + String(describing: batterLabel.frame.origin.y))
		if (batterLabel.frame.origin.x > 135 && batterLabel.frame.origin.x < 235) {
			if (batterLabel.frame.origin.y > 515 && batterLabel.frame.origin.y < 545) {
				runs += 1
				player1pos = 3
			} else if (batterLabel.frame.origin.y > 360 && batterLabel.frame.origin.y < 390) {
				second = playerid
				player1pos = 1
			}
		}
		if (batterLabel.frame.origin.y > 435 && batterLabel.frame.origin.y < 465) {
			if (batterLabel.frame.origin.x > 65 && batterLabel.frame.origin.x < 165) {
				third = playerid
				player1pos = 2
			} else if (batterLabel.frame.origin.x > 205 && batterLabel.frame.origin.x < 305) {
				first = playerid
				player1pos = 0
			}
		}
		if (batterLabel.frame.origin.y > 230 && batterLabel.frame.origin.y < 280) {
			outCheck += 1
			player1pos = 4
		}
		
		if (label1st.frame.origin.x > 135 && label1st.frame.origin.x < 235) {
			if (label1st.frame.origin.y > 515 && label1st.frame.origin.y < 545) {
				runs += 1
				player2pos = 3
			} else if (label1st.frame.origin.y > 360 && label1st.frame.origin.y < 390) {
				second = bases[0]
				player2pos = 1
			}
		}
		if (label1st.frame.origin.y > 435 && label1st.frame.origin.y < 465) {
			if (label1st.frame.origin.x > 65 && label1st.frame.origin.x < 165) {
				third = bases[0]
				player2pos = 2
			} else if (label1st.frame.origin.x > 205 && label1st.frame.origin.x < 305) {
				first = bases[0]
				player2pos = 0
			}
		}
		if (label1st.frame.origin.y > 230 && label1st.frame.origin.y < 280) {
			outCheck += 1
			player2pos = 4
		}
		
		if (label2nd.frame.origin.x > 135 && label2nd.frame.origin.x < 235) {
			if (label2nd.frame.origin.y > 515 && label2nd.frame.origin.y < 545) {
				runs += 1
				player3pos = 3
			} else if (label2nd.frame.origin.y > 360 && label2nd.frame.origin.y < 390) {
				second = bases[1]
				player3pos = 1
			}
		}
		if (label2nd.frame.origin.y > 435 && label2nd.frame.origin.y < 465) {
			if (label2nd.frame.origin.x > 65 && label2nd.frame.origin.x < 165) {
				third = bases[1]
				player3pos = 2
			} else if (label2nd.frame.origin.x > 205 && label2nd.frame.origin.x < 305) {
				first = bases[1]
				player3pos = 0
			}
		}
		if (label2nd.frame.origin.y > 230 && label2nd.frame.origin.y < 280) {
			outCheck += 1
			player3pos = 4
		}
		
		if (label3rd.frame.origin.x > 135 && label3rd.frame.origin.x < 235) {
			if (label3rd.frame.origin.y > 515 && label3rd.frame.origin.y < 545) {
				runs += 1
				player4pos = 3
			} else if (label3rd.frame.origin.y > 360 && label3rd.frame.origin.y < 390) {
				second = bases[2]
				player4pos = 1
			}
		}
		if (label3rd.frame.origin.y > 435 && label3rd.frame.origin.y < 465) {
			if (label3rd.frame.origin.x > 65 && label3rd.frame.origin.x < 165) {
				third = bases[2]
				player4pos = 2
			} else if (label3rd.frame.origin.x > 205 && label3rd.frame.origin.x < 305) {
				first = bases[2]
				player4pos = 0
			}
		}
		if (label3rd.frame.origin.y > 230 && label3rd.frame.origin.y < 280) {
			outCheck += 1
			player4pos = 4
		}
		// Check
		if ((player1pos == -1) || (player2pos == -1 && bases[0] > -1) || (player3pos == -1 && bases[1] > -1) || (player4pos == -1 && bases[2] > -1)) {
			if (player1pos == -1) {NSLog("Player 1 not positioned: " + String(describing: batterLabel.frame.origin.x) + ", " + String(describing: batterLabel.frame.origin.y))}
			if (player2pos == -1 && bases[0] > -1) {NSLog("Player 2 not positioned: " + String(describing: label1st.frame.origin.x) + ", " + String(describing: label1st.frame.origin.y))}
			if (player3pos == -1 && bases[1] > -1) {NSLog("Player 3 not positioned: " + String(describing: label2nd.frame.origin.x) + ", " + String(describing: label2nd.frame.origin.y))}
			if (player4pos == -1 && bases[2] > -1) {NSLog("Player 4 not positioned: " + String(describing: label3rd.frame.origin.x) + ", " + String(describing: label3rd.frame.origin.y))}
			let alert = UIAlertController(title: "Field unchanged", message: "Please move all players into position before pressing Save.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}
		let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: "CheckController")
		self.present(loginPageView!, animated: true, completion: nil)
		while (true) {
			if (checkCustomSave[0]) {break}
		}
		if (!checkCustomSave[1]) {return}
		// Finish saving
		bases[0] = first
		bases[1] = second
		bases[2] = third
		if (inntop) {awayScore += runs}
		else {homeScore += runs}
		outs += outCheck
		playerid += 1
		// Exit
		let appDelegate  = UIApplication.shared.delegate as! AppDelegate
		let viewController = appDelegate.window!.rootViewController as! OverviewViewer
		viewController.updateText()
		let tmpController :UIViewController! = self.presentingViewController;
        self.dismiss(animated: true, completion: {()->Void in
		tmpController.dismiss(animated: true, completion: nil);
        })
	}
	
}

class CheckController: UIViewController {

	@IBOutlet var PlayerTable: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
		let tmpController : CustomController! = self.presentingViewController as! CustomController!;
		if (inntop) {
			firstBase.text = tmpController.first > -1 ? "Player " + String(tmpController.first + 1) : " "
			secondBase.text = tmpController.second > -1 ? "Player " + String(tmpController.second + 1) : " "
			thirdBase.text = tmpController.third > -1 ? "Player " + String(tmpController.third + 1) : " "
		} else {
			firstBase.text = tmpController.first > -1 ? players[tmpController.first] : " "
			secondBase.text = tmpController.second > -1 ? players[tmpController.second] : " "
			thirdBase.text = tmpController.third > -1 ? players[tmpController.third] : " "
		}
		runsText.text = String(tmpController.runs)
		outsText.text = String(tmpController.outCheck)
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet var firstBase: UILabel!
	@IBOutlet var secondBase: UILabel!
	@IBOutlet var thirdBase: UILabel!
	@IBOutlet var runsText: UILabel!
	@IBOutlet var outsText: UILabel!
	
	@IBAction func cancel(_ sender: Any) {
		checkCustomSave = [true, false]
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func save(_ sender: Any) {
		checkCustomSave = [true, true]
		self.dismiss(animated: true, completion: nil)
	}

}
