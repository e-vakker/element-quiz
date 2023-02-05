//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Jevgeni Vakker on 23.08.2022.
//

import UIKit

enum Mode {
    case flashCard
    case quiz
}

enum State {
    case question
    case answer
    case score
}

enum Shuffle {
    case predictable
    case randomized
}

enum ModeLearn {
    case deleteLearned
    case allLearn
}

class ViewController: UIViewController, UITextFieldDelegate {
    //  Outlets for interface
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var deleteLearnedButton: UIButton!
    @IBOutlet weak var shuffleSelector: UISegmentedControl!
    @IBOutlet weak var mistakeItem: UIView!
    
    
    var mode: Mode = .flashCard {
        didSet {
           restartingApp()
        }
    }
    
    var shuffle: Shuffle = .predictable {
        didSet {
           restartingApp()
        }
    }
    var state: State = .question
    var modeLearn: ModeLearn = .allLearn
    //  List of chemical elements and initializer of the current index
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    var learningItemsList: [String] = []
    var mistakesItemsList: [String] = []
    var currentElemetIndex = 0
    // Quiz-specific state
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
        modeLearn = .allLearn
    }
    //  Updates the app's UI in flash card mode.
    func updateFlashCardUI(_ elementName: String) {
        // Text field and keyboard
        textField.isHidden = true
        textField.resignFirstResponder()
        // Buttons
        showAnswerButton.isHidden = false
        deleteLearnedButton.isHidden = true
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        // Answer label
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        // Segmented control
        modeSelector.selectedSegmentIndex = 0
    }
    // Update the app's UI in quiz mode.
    func updateQuizUI(_ elementName: String) {
        // Text field and keyboard
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        // Buttons
        showAnswerButton.isHidden = true
        deleteLearnedButton.isHidden = false
        if learningItemsList.count >= 1 {
            deleteLearnedButton.isEnabled = true
        } else {
            deleteLearnedButton.isEnabled = false
        }
        if currentElemetIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        // Answer label
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct"
            } else {
                answerLabel.text = "❌\nCorrect answer: \(elementName)"
            }
        case .score:
            answerLabel.text = ""
        }
        // Score display
        if state == .score {
            displayScoreAlert()
        }
        modeSelector.selectedSegmentIndex = 1
        
    }
    // Updates the app UI based on its mode and state.
    func updateUI() {
        switchDeleteLearned()
        let elementName = elementList[currentElemetIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        if mistakesItemsList.contains(elementName.lowercased()) {
            mistakeItem.backgroundColor = .systemRed
        } else {
            mistakeItem.backgroundColor = .systemBackground
        }
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName)
        case .quiz:
            updateQuizUI(elementName)
        }
    }
    // Runs after the user hits the Return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Get the text from the text field
        let textFieldContents = textField.text!
        let element = elementList[currentElemetIndex].lowercased()
        // Determine whether the user answered correctly and update appropriate quiz
        // State
        if textFieldContents.lowercased() == element {
            // Add to the array with correct answers
            if learningItemsList.contains(element) == false {
                learningItemsList.append(element)
            }
            if mistakesItemsList.contains(element) == true {
                if let index = mistakesItemsList.firstIndex(of: element) {
                mistakesItemsList.remove(at: index)
                }
            }
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            // Add to the array with mistakes answers
            if mistakesItemsList.contains(element) == false {
                mistakesItemsList.append(element)
            }
            if learningItemsList.contains(element) == true {
                if let index = learningItemsList.firstIndex(of: element) {
                    learningItemsList.remove(at: index)
                }
            }
            answerIsCorrect = false
        }
        // The app should now display the answer to the user
        state = .answer
        updateUI()
        
        return true
    }
    
    // Shows an IOS alert with the user's quiz score.
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    // Sets up a new flash card session.
    func setupFlashCards() {
        state = .question
        currentElemetIndex = 0
    }
    
    func setupQuiz() {
        state = .question
        currentElemetIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    // Make cards random or predetermined
    func shuffleCards () {
        elementList.removeAll()
        switch shuffle {
        case .predictable:
            switch modeLearn {
            case .deleteLearned:
                for element in fixedElementList {
                    if !learningItemsList.contains(element.lowercased()) {
                        elementList.append(element)
                    }
                }
            case .allLearn:
                elementList = fixedElementList
            }
        case .randomized:
            switch modeLearn {
            case .deleteLearned:
                for element in fixedElementList {
                    if !learningItemsList.contains(element.lowercased()) {
                        elementList.append(element)
                    }
                }
                elementList = elementList.shuffled()
            case .allLearn:
                elementList = fixedElementList.shuffled()
            }
        }
    }
    
    func switchDeleteLearned () {
        switch modeLearn {
        case .deleteLearned:
            deleteLearnedButton.setTitle("All items", for: .normal)
            if learningItemsList.count == fixedElementList.count {
                modeLearn = .allLearn
                learningItemsList.removeAll()
                mistakesItemsList.removeAll()
                elementList.removeAll()
                restartingApp()
            }
        case .allLearn:
            deleteLearnedButton.setTitle("Delete learned", for: .normal)
        }
    }
    
    func restartingApp () {
        switch mode {
        case .flashCard:
            setupFlashCards()
        case .quiz:
            setupQuiz()
        }
        shuffleCards()
        switchDeleteLearned()
        updateUI()
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        state = .answer
        
        updateUI()
    }
    
    @IBAction func next(_ sender: Any) {
        currentElemetIndex += 1
        if currentElemetIndex >= elementList.count {
            currentElemetIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        updateUI()
    }
    
    @IBAction func switchModes(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    @IBAction func switchShaffle(_ sender: Any) {
        if shuffleSelector.selectedSegmentIndex == 0 {
            shuffle = .predictable
        } else {
            shuffle = .randomized
        }
        
    }
    @IBAction func deleteLearned(_ sender: Any) {
        if modeLearn == .allLearn {
            modeLearn = .deleteLearned
        } else {
            modeLearn = .allLearn
        }
        restartingApp()
    }
}

