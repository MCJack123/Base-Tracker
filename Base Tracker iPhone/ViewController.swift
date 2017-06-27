//
//  ViewController.swift
//  Base Tracker iPhone
//
//  Created by Jack Bruienne on 7/19/16.
//  Copyright © 2016 MCJack123. All rights reserved.
//

import UIKit

class Player {
    var name: String {
		get {
			if (customName == nil) {
				return "Player " + String(id)
			} else {
				return customName!
			}
		}
		set(v) {
			customName = v
		}
    }
	var customName: String?
    var id: Int
    var timesAtBat: Int = 0
    var totalBalls: Int = 0
    var totalStrikes: Int = 0
    var totalOuts: Int = 0
    var totalRuns: Int = 0
    var totalHits: Int = 0
    var totalFouls: Int = 0
	
	init(number: Int, customName: String? = nil) {
		self.id = number
		self.customName = customName
	}
	
	static func == (left: Player, right: Player) -> Bool {
		return (left.id == right.id && left.name == right.name)
	}
}

class Team {
    var name: String
    var side: IST = .top
    var playerCount: Int {
        return players.count
    }
    var players: [Player] = [Player]()
	
	init(name teamName: String, count teamCount: Int) {
		self.name = teamName
		var tc = teamCount
		while tc >= 0 {
			self.players[tc-1] = Player(number: tc)
			tc-=1
		}
	}
	
	func getBatter(_ last: Player, _ side: IST) -> Player? {
		if (self.side == side) {
			for player in self.players {
				if player.id == incWithMax(variable: last.id, max: self.playerCount - 1, min: 1) {
					return player
				}
			}
		}
		return nil
	}
}

enum GameActionType {
	case Strike
	case Ball
	case Hit
	case Foul
	case Walk
	case Move1st
	case Move2nd
	case Move3rd
	case MoveHome
	case MoveOut
	case NextBatter
}

enum IST: String {
	case top = "Top"
	case bottom = "Bottom"
}

func reverseIST(_ operand: IST) -> IST {
	if (operand == .top) {
		return .bottom
	} else {
		return .top
	}
}

struct GameAction {
	var player: Player
	var action: GameActionType
	var notes: String
}

class GameState {
	var strikes: Int = 0
	var balls: Int = 0
	var outs: Int = 0
	var inningSide: IST = IST.top
	var inning: Int = 1
	var homeRuns: Int = 0
	var awayRuns: Int = 0
	var lastSideBatter: Player = Player(number: 1)
	var playerPositions: [Player?] = Array(repeating: nil, count: 4)
	var getBatter: (Player, IST) -> Player
	var actions: [GameAction] = [GameAction]()
	
	init(_ getf: @escaping (Player, IST) -> Player) {
		self.getBatter = getf
		self.playerPositions[0] = getf(Player(number: 0), inningSide)
	}
	
	init(fromActions actions: [GameAction], getBatterFunction getf: @escaping (Player, IST) -> Player) {
		self.getBatter = getf
		self.playerPositions[0] = getf(Player(number: 0), inningSide)
		self.actions = actions
		for action in actions {
			self.doAction(action)
		}
	}
	
	init(asCloneOf clone: GameState) {
		self.strikes = clone.strikes
		self.balls = clone.balls
		self.outs = clone.outs
		self.inningSide = clone.inningSide
		self.inning = clone.inning
		self.homeRuns = clone.homeRuns
		self.awayRuns = clone.awayRuns
		self.lastSideBatter = clone.lastSideBatter
		self.playerPositions = clone.playerPositions
		self.getBatter = clone.getBatter
		self.actions = clone.actions
	}
	
	func doAction(_ action: GameAction) {
		switch action.action {
		case .Strike:
			self.strikes += 1
			if let player: Int = find(action.player) {
				self.playerPositions[player]!.totalStrikes += 1
			}
		case .Ball:
			self.balls += 1
			if let player: Int = find(action.player) {
				self.playerPositions[player]!.totalBalls += 1
			}
		case .Hit:
			self.playerPositions[0]?.totalHits += 1
		case .Move1st:
			self.playerPositions[1] = action.player
			if let player: Int = find(action.player) {
				self.playerPositions[player] = nil
			}
		case .Move2nd:
			self.playerPositions[2] = action.player
			if let player: Int = find(action.player) {
				self.playerPositions[player] = nil
			}
		case .Move3rd:
			self.playerPositions[3] = action.player
			if let player: Int = find(action.player) {
				self.playerPositions[player] = nil
			}
		case .MoveHome:
			if (self.inningSide == .top) {
				self.awayRuns += 1
			} else {
				self.homeRuns += 1
			}
			if let player: Int = find(action.player) {
				self.playerPositions[player]!.totalRuns += 1
				self.playerPositions[player] = nil
			}
		case .MoveOut:
			self.outs += 1
			if let player: Int = find(action.player) {
				self.playerPositions[player]!.totalBalls += 1
				self.playerPositions[player] = nil
			}
		case .Walk:
			var i = 1
			while i <= 3 {
				if (self.playerPositions[i] == nil) {
					break
				}
				i+=1
			}
			while i > 0 {
				if (i == 3) {
					if (self.inningSide == .top) {
						self.awayRuns += 1
					} else {
						self.homeRuns += 1
					}
				} else {
					self.playerPositions[i+1] = self.playerPositions[i]
				}
				i-=1
			}
			self.playerPositions[1] = self.playerPositions[0]
			self.playerPositions[0] = getBatter(self.playerPositions[0]!, self.inningSide)
		case .Foul:
			if (self.strikes < 2) {
				self.strikes += 1
			}
			if let player: Int = find(action.player) {
				self.playerPositions[player]!.totalFouls += 1
			}
		case .NextBatter:
			self.playerPositions[0] = getBatter(self.playerPositions[0]!, self.inningSide)
			self.strikes = 0
			self.balls = 0
		}
		self.actions.append(action)
		updateStats()
	}
	
	private func updateStats() {
		if (self.strikes > 2) {
			self.strikes = 0
			self.balls = 0
			self.outs += 1
			self.playerPositions[0] = getBatter(self.playerPositions[0]!, self.inningSide)
		}
		if (self.balls > 3) {
			self.balls = 0
			self.strikes = 0
			doAction(GameAction(player: Player(number: 0), action: .Walk, notes: ""))
		}
		if (self.outs > 2) {
			self.inningSide = reverseIST(self.inningSide)
			if (inningSide == .top) {
				inning += 1
			}
			self.strikes = 0
			self.balls = 0
			self.outs = 0
			let lastBuffer = self.lastSideBatter
			self.lastSideBatter = self.playerPositions[0]!
			self.playerPositions = [Player?]()
			self.playerPositions[0] = getBatter(lastBuffer, self.inningSide)
		}
	}
	
	private func find(_ player: Player) -> Int? {
		var posn = 0
		for pos in self.playerPositions {
			if (pos! == player) {
				return posn
			}
			posn+=1
		}
		return nil
	}
}

func incWithMax(variable: Int, max: Int, min: Int = 0) -> Int {
	if (variable + 1 > max) {
		return min
	}
	else {
		return variable + 1
	}
}

var defaults: UserDefaults = UserDefaults.standard
var registered = false

func registerSettingsBundle() {
    let appDefaults = [String:AnyObject]()
    UserDefaults.standard.register(defaults: appDefaults)
    registered = true
}

func updateDisplayFromDefaults(){
    //Get the defaults
    defaults = UserDefaults.standard
}

var thisTeam = Team(name: defaults.string(forKey: "tname")!, count: 20)
var otherTeam = Team(name: "Opposing Team", count: defaults.integer(forKey: "oppnum"))

func getBatter(_ last: Player, _ inn: IST) -> Player {
	let player = thisTeam.getBatter(last, inn)
	if (player == nil) {
		return player!
	} else {
		return otherTeam.getBatter(last, inn)!
	}
}

var currentGameState = GameState(getBatter)
var backupGameState = GameState(getBatter)

func doAction(_ action: GameAction) {
	currentGameState.doAction(action)
}

func makeBackup() {
	backupGameState = GameState(asCloneOf: currentGameState)
}

func swapStates() {
	let buffer = GameState(asCloneOf: currentGameState)
	currentGameState = GameState(asCloneOf: backupGameState)
	backupGameState = buffer
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
        let alert = UIAlertController(title: "Unimplemented!", message: "This feature is not supported in this build of Base Tracker.", preferredStyle: UIAlertControllerStyle.alert)
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
		strikesText.text = String(currentGameState.strikes)
		ballsText.text = String(currentGameState.balls)
		outsText.text = String(currentGameState.outs)
		awayScoreText.text = String(currentGameState.awayRuns)
		homeScoreText.text = String(currentGameState.homeRuns)
		if (currentGameState.inning % 10 == 1) {
			inningText.text = String(currentGameState.inning) + "st"
		} else if (currentGameState.inning % 10 == 2) {
			inningText.text = String(currentGameState.inning) + "nd"
		} else if (currentGameState.inning % 10 == 3) {
			inningText.text = String(currentGameState.inning) + "rd"
		} else {
			inningText.text = String(currentGameState.inning) + "th"
		}
		print("1")
		runner1.text  = currentGameState.playerPositions[1] != nil ? currentGameState.playerPositions[1]!.name : " "
		runner2.text  = currentGameState.playerPositions[2] != nil ? currentGameState.playerPositions[2]!.name : " "
		runner3.text  = currentGameState.playerPositions[3] != nil ? currentGameState.playerPositions[3]!.name : " "
		print("2")
		tbText.text = currentGameState.inningSide.rawValue
	}
	
	@IBAction func addBat(_ sender: Any) {
		var currentAction = GameAction(player: currentGameState.playerPositions[0]!, action: .Strike, notes: "")
		switch batSelector.selectedSegmentIndex {
		case 0:
			currentAction.action = .Strike
		case 1:
			currentAction.action = .Ball
		case 2:
			let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: "HitController")
			self.present(loginPageView!, animated: true, completion: updateText)
			return
        case 3:
            currentAction.action = .Foul
		default:
			NSLog("Help! Bat selector is not a value!")
			return
		}
		makeBackup()
		doAction(currentAction)
		updateText()
	}
	
	@IBAction func undoAction(_ sender: Any) {
		swapStates()
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
	
	var testbases = [Player?]()
	var homeRunners = [Player]()
	var checkOutters = [Player]()
	var beenHit = false

	override func viewDidLoad() {
		super.viewDidLoad()
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
		player.text = currentGameState.playerPositions[0] != nil ? currentGameState.playerPositions[0]!.name : " "
		base1.text  = currentGameState.playerPositions[1] != nil ? currentGameState.playerPositions[1]!.name : " "
		base2.text  = currentGameState.playerPositions[2] != nil ? currentGameState.playerPositions[2]!.name : " "
		base3.text  = currentGameState.playerPositions[3] != nil ? currentGameState.playerPositions[3]!.name : " "
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func updateText() {
		base1.text  = currentGameState.playerPositions[1] != nil ? currentGameState.playerPositions[1]!.name : " "
		base2.text  = currentGameState.playerPositions[2] != nil ? currentGameState.playerPositions[2]!.name : " "
		base3.text  = currentGameState.playerPositions[3] != nil ? currentGameState.playerPositions[3]!.name : " "
		runsText.text = String(homeRunners.count)
		outsText.text = String(checkOutters.count)
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
		makeBackup()
		doAction(GameAction(player: testbases[0]!, action: .Move1st, notes: ""))
		doAction(GameAction(player: testbases[1]!, action: .Move2nd, notes: ""))
		doAction(GameAction(player: testbases[2]!, action: .Move3rd, notes: ""))
		for run in homeRunners {
			doAction(GameAction(player: run, action: .MoveHome, notes: ""))
		}
		for out in checkOutters {
			doAction(GameAction(player: out, action: .MoveOut, notes: ""))
		}
		doAction(GameAction(player: Player(number: 0), action: .NextBatter, notes: ""))
		// Exit
		let appDelegate  = UIApplication.shared.delegate as! AppDelegate
		let viewController = appDelegate.window!.rootViewController as! OverviewViewer
		viewController.updateText()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func move1st(_ sender: Any) {
		testbases[0] = currentGameState.playerPositions[0]
		testbases[1] = currentGameState.playerPositions[1]
		testbases[2] = currentGameState.playerPositions[2]
		homeRunners = [Player]()
		if (currentGameState.playerPositions[3] != nil) {homeRunners.append(currentGameState.playerPositions[3]!)}
		checkOutters = [Player]()
		updateText()
	}
	
	@IBAction func move2nd(_ sender: Any) {
		testbases[0] = nil
		testbases[1] = currentGameState.playerPositions[0]
		testbases[2] = currentGameState.playerPositions[1]
		homeRunners = [Player]()
		if (currentGameState.playerPositions[2] != nil) {homeRunners.append(currentGameState.playerPositions[2]!)}
		if (currentGameState.playerPositions[3] != nil) {homeRunners.append(currentGameState.playerPositions[3]!)}
		checkOutters = [Player]()
		updateText()
	}
	
	@IBAction func move3rd(_ sender: Any) {
		testbases[0] = nil
		testbases[1] = nil
		testbases[2] = currentGameState.playerPositions[0]
		homeRunners = [Player]()
		if (currentGameState.playerPositions[1] != nil) {homeRunners.append(currentGameState.playerPositions[1]!)}
		if (currentGameState.playerPositions[2] != nil) {homeRunners.append(currentGameState.playerPositions[2]!)}
		if (currentGameState.playerPositions[3] != nil) {homeRunners.append(currentGameState.playerPositions[3]!)}
		checkOutters = [Player]()
		updateText()
	}
	
	@IBAction func move4th(_ sender: Any) {
		homeRunners = [currentGameState.playerPositions[0]!]
		if (currentGameState.playerPositions[1] != nil) {homeRunners.append(currentGameState.playerPositions[1]!)}
		if (currentGameState.playerPositions[2] != nil) {homeRunners.append(currentGameState.playerPositions[2]!)}
		if (currentGameState.playerPositions[3] != nil) {homeRunners.append(currentGameState.playerPositions[3]!)}
		testbases[0] = nil
		testbases[1] = nil
		testbases[2] = nil
		checkOutters = [Player]()
		updateText()
	}
	
	@IBAction func moveOut(_ sender: Any) {
		move1st(sender)
		checkOutters = [currentGameState.playerPositions[0]!]
		testbases[0] = nil
		updateText()
	}
	
	@IBAction func flyOut(_ sender: Any) {
		checkOutters = [currentGameState.playerPositions[0]!]
		testbases[0] = currentGameState.playerPositions[1]
		testbases[1] = currentGameState.playerPositions[2]
		testbases[2] = currentGameState.playerPositions[3]
		homeRunners = [Player]()
		updateText()
	}
	
	@IBAction func customHit(_ sender: Any) {
		let alert = UIAlertController(title: "Unimplemented!", message: "This feature is not supported in this build of Base Tracker.", preferredStyle: UIAlertControllerStyle.alert)
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
		batterLabel.text = currentGameState.playerPositions[0]!.name
		if (currentGameState.playerPositions[1] == nil) {label1st.isHidden = true}
		else {label1st.text = currentGameState.playerPositions[1]!.name}
		if (currentGameState.playerPositions[2] == nil) {label2nd.isHidden = true}
		else {label2nd.text = currentGameState.playerPositions[2]!.name}
		if (currentGameState.playerPositions[3] == nil) {label3rd.isHidden = true}
		else {label3rd.text = currentGameState.playerPositions[3]!.name}
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
	
	var third: Player? = nil
	var second: Player? = nil
	var first: Player? = nil
	var runs = [Player]()
	var outCheck = [Player]()
	@IBAction func save(_ sender: Any) {
		third = nil
		second = nil
		first = nil
		runs = [Player]()
		outCheck = [Player]()
		// -1 = not set, 0 = first, 1 = second, 2 = third, 3 = home, 4 = out
		var player1pos = -1
		var player2pos = -1
		var player3pos = -1
		var player4pos = -1
		// Save
		NSLog(String(describing: batterLabel.frame.origin.x) + ", " + String(describing: batterLabel.frame.origin.y))
		if (batterLabel.frame.origin.x > 135 && batterLabel.frame.origin.x < 235) {
			if (batterLabel.frame.origin.y > 515 && batterLabel.frame.origin.y < 545) {
				runs.append(currentGameState.playerPositions[0]!)
				player1pos = 3
			} else if (batterLabel.frame.origin.y > 360 && batterLabel.frame.origin.y < 390) {
				second = currentGameState.playerPositions[0]!
				player1pos = 1
			}
		}
		if (batterLabel.frame.origin.y > 435 && batterLabel.frame.origin.y < 465) {
			if (batterLabel.frame.origin.x > 65 && batterLabel.frame.origin.x < 165) {
				third = currentGameState.playerPositions[0]!
				player1pos = 2
			} else if (batterLabel.frame.origin.x > 205 && batterLabel.frame.origin.x < 305) {
				first = currentGameState.playerPositions[0]!
				player1pos = 0
			}
		}
		if (batterLabel.frame.origin.y > 230 && batterLabel.frame.origin.y < 280) {
			outCheck.append(currentGameState.playerPositions[0]!)
			player1pos = 4
		}
		
		if (label1st.frame.origin.x > 135 && label1st.frame.origin.x < 235) {
			if (label1st.frame.origin.y > 515 && label1st.frame.origin.y < 545) {
				runs.append(currentGameState.playerPositions[1]!)
				player2pos = 3
			} else if (label1st.frame.origin.y > 360 && label1st.frame.origin.y < 390) {
				second = currentGameState.playerPositions[1]!
				player2pos = 1
			}
		}
		if (label1st.frame.origin.y > 435 && label1st.frame.origin.y < 465) {
			if (label1st.frame.origin.x > 65 && label1st.frame.origin.x < 165) {
				third = currentGameState.playerPositions[1]!
				player2pos = 2
			} else if (label1st.frame.origin.x > 205 && label1st.frame.origin.x < 305) {
				first = currentGameState.playerPositions[1]!
				player2pos = 0
			}
		}
		if (label1st.frame.origin.y > 230 && label1st.frame.origin.y < 280) {
			outCheck.append(currentGameState.playerPositions[1]!)
			player2pos = 4
		}
		
		if (label2nd.frame.origin.x > 135 && label2nd.frame.origin.x < 235) {
			if (label2nd.frame.origin.y > 515 && label2nd.frame.origin.y < 545) {
				runs.append(currentGameState.playerPositions[2]!)
				player3pos = 3
			} else if (label2nd.frame.origin.y > 360 && label2nd.frame.origin.y < 390) {
				second = currentGameState.playerPositions[2]!
				player3pos = 1
			}
		}
		if (label2nd.frame.origin.y > 435 && label2nd.frame.origin.y < 465) {
			if (label2nd.frame.origin.x > 65 && label2nd.frame.origin.x < 165) {
				third = currentGameState.playerPositions[2]!
				player3pos = 2
			} else if (label2nd.frame.origin.x > 205 && label2nd.frame.origin.x < 305) {
				first = currentGameState.playerPositions[2]!
				player3pos = 0
			}
		}
		if (label2nd.frame.origin.y > 230 && label2nd.frame.origin.y < 280) {
			outCheck.append(currentGameState.playerPositions[2]!)
			player3pos = 4
		}
		
		if (label3rd.frame.origin.x > 135 && label3rd.frame.origin.x < 235) {
			if (label3rd.frame.origin.y > 515 && label3rd.frame.origin.y < 545) {
				runs.append(currentGameState.playerPositions[3]!)
				player4pos = 3
			} else if (label3rd.frame.origin.y > 360 && label3rd.frame.origin.y < 390) {
				second = currentGameState.playerPositions[3]!
				player4pos = 1
			}
		}
		if (label3rd.frame.origin.y > 435 && label3rd.frame.origin.y < 465) {
			if (label3rd.frame.origin.x > 65 && label3rd.frame.origin.x < 165) {
				third = currentGameState.playerPositions[3]!
				player4pos = 2
			} else if (label3rd.frame.origin.x > 205 && label3rd.frame.origin.x < 305) {
				first = currentGameState.playerPositions[3]!
				player4pos = 0
			}
		}
		if (label3rd.frame.origin.y > 230 && label3rd.frame.origin.y < 280) {
			outCheck.append(currentGameState.playerPositions[3]!)
			player4pos = 4
		}
		// Check
		if ((player1pos == -1) || (player2pos == -1 && currentGameState.playerPositions[1] != nil) || (player3pos == -1 && currentGameState.playerPositions[2] != nil) || (player4pos == -1 && currentGameState.playerPositions[3] != nil)) {
			if (player1pos == -1) {NSLog("Player 1 not positioned: " + String(describing: batterLabel.frame.origin.x) + ", " + String(describing: batterLabel.frame.origin.y))}
			if (player2pos == -1 && currentGameState.playerPositions[1] != nil) {NSLog("Player 2 not positioned: " + String(describing: label1st.frame.origin.x) + ", " + String(describing: label1st.frame.origin.y))}
			if (player3pos == -1 && currentGameState.playerPositions[2] != nil) {NSLog("Player 3 not positioned: " + String(describing: label2nd.frame.origin.x) + ", " + String(describing: label2nd.frame.origin.y))}
			if (player4pos == -1 && currentGameState.playerPositions[3] != nil) {NSLog("Player 4 not positioned: " + String(describing: label3rd.frame.origin.x) + ", " + String(describing: label3rd.frame.origin.y))}
			let alert = UIAlertController(title: "Field unchanged", message: "Please move all players into position before pressing Save.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}
        print("Adding view")
		let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: "CheckController") as! CheckController?
        if (loginPageView == nil) {
            print("CheckController is not defined! setting breakpoint here")
            print("Error")
        }
        loginPageView!.tmpController = self
        print("Presenting")
        self.present(loginPageView!, animated: true, completion: nil)
	}
	
}

class CheckController: UIViewController {

	@IBOutlet var PlayerTable: UITableView!
    var tmpController : CustomController? = nil
    
	override func viewDidLoad() {
        print("Loading")
		super.viewDidLoad()
		let navigationBarHeight: CGFloat = 64.0
		let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: navigationBarHeight)
		let bar = UINavigationBar(frame: frame)
		bar.items = [self.navigationItem]
		self.view.addSubview(bar)
        print("Getting presenter")
        if (tmpController == nil) {
            print("Presenting view controller is nil! setting breakpoint here")
            print("Error")
        }
        //let tmpController : CustomController = self.presentingViewController! as! CustomController;
		firstBase.text = tmpController!.first != nil ? tmpController!.first!.name : " "
		secondBase.text = tmpController!.second != nil ? tmpController!.second!.name : " "
        thirdBase.text = tmpController!.third != nil ? tmpController!.third!.name : " "
        runsText.text = String(tmpController!.runs.count)
        outsText.text = String(tmpController!.outCheck.count)
        print("Done")
		// Do any additional setup after loading the view, typically from a nib.
	}
    
    /*override func viewWillAppear(_ animated: Bool) {
        print("Getting presenter")
        if (tmpController == nil) {
            print("Presenting view controller is nil! setting breakpoint here")
            print("Error")
        }
        //let tmpController : CustomController = self.presentingViewController! as! CustomController;
        if (inntop) {
            firstBase.text = tmpController!.first > -1 ? "Player " + String(tmpController!.first + 1) : " "
            secondBase.text = tmpController!.second > -1 ? "Player " + String(tmpController!.second + 1) : " "
            thirdBase.text = tmpController!.third > -1 ? "Player " + String(tmpController!.third + 1) : " "
        } else {
            firstBase.text = tmpController!.first > -1 ? players[tmpController!.first] : " "
            secondBase.text = tmpController!.second > -1 ? players[tmpController!.second] : " "
            thirdBase.text = tmpController!.third > -1 ? players[tmpController!.third] : " "
        }
        runsText.text = String(tmpController!.runs)
        outsText.text = String(tmpController!.outCheck)
        print("Done")
    }*/

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
		//checkCustomSave = [true, false]
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func save(_ sender: Any) {
		//checkCustomSave = [true, true]
        // Finish saving
		makeBackup()
        if (tmpController!.first != nil) {doAction(GameAction(player: tmpController!.first!, action: .Move1st, notes: ""))}
        if (tmpController!.second != nil) {doAction(GameAction(player: tmpController!.second!, action: .Move2nd, notes: ""))}
        if (tmpController!.third != nil) {doAction(GameAction(player: tmpController!.third!, action: .Move3rd, notes: ""))}
        for run in tmpController!.runs {
			doAction(GameAction(player: run, action: .MoveHome, notes: ""))
		}
		for out in tmpController!.outCheck {
			doAction(GameAction(player: out, action: .MoveOut, notes: ""))
		}
        doAction(GameAction(player: Player(number: -1), action: .NextBatter, notes: ""))
        // Exit
        if (tmpController!.presentingViewController?.presentingViewController == nil) {
            if (tmpController!.presentingViewController == nil) {
                print("self.parent is not defined! setting breakpoint here")
                print("Error")
            } else {
                print("self.parent.parent is not defined! setting breakpoint here")
                print("Error")
            }
        }
        //print("breaking")
        (tmpController!.presentingViewController?.presentingViewController as! OverviewViewer).updateText()
        let tmpController2 : UIViewController! = tmpController!.presentingViewController;
        tmpController2.presentingViewController!.dismiss(animated: true, completion: nil)
		self.dismiss(animated: true, completion: nil)
	}

}
