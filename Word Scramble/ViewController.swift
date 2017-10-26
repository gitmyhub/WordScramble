//
//  ViewController.swift
//  Word Scramble
//
//  Created by ajay on 10/26/17.
//  Copyright © 2017 Brother International. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt"){
        if let startWords = try? String(contentsOfFile: startWordsPath){
                allWords = startWords.components(separatedBy: "\n")
            }
            
        }else{
            allWords = ["silkworm"]
        }
        startGame()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
        
    }
    func startGame(){
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        
    }
    
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert )
        //addTextField() method just adds an editable text input field to the UIAlertController
        ac.addTextField()
        //trailing closure syntax. Any time you are calling a method that expects a closure as its final parameter
       //That code will use self and ac so we declare them as being unowned so that Swift won’t accidentally create a strong reference cycle
        //Everything after in is the actual code of the closure.
        //Inside the closure we need to reference methods on our view controller using self so that we’re clearly acknowledging the possibility of a strong reference cycle.
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        //addAction() method is used to add a UIAlertAction to a UIAlertController
        ac.addAction(submitAction)
        present(ac, animated: true)
        
    }
    
    func submit(answer: String){
        let lowerAnswer = answer.lowercased()
        let errorTitle: String
        let errorMessage: String
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row:0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else{
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else{
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word{
            if let pos = tempWord.range(of: String(letter)){
                tempWord.remove(at: pos.lowerBound)
            } else{
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
        
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count) //make a string range, which is a value that holds a start position and a length.
        //when you’re working with UIKit, SpriteKit, or any other Apple framework, use utf16.count for the character count. If it’s just your own code - i.e. looping over characters and processing each one individually – then use count instead.
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en") //rangeOfMisspelledWord(in:) returns an NSRange structure, which tells us where the misspelling was found
        return misspelledRange.location == NSNotFound //if nothing was found our NSRange will have the special location NSNotFound
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

