//
//  ContentView.swift
//  WordScramble
//
//  Created by sebastian.popa on 8/2/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var rootWordMinLength = 4
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word:", text: $newWord)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled(true)
                }
                
                Section {
                    Text("Your current score is \(score)")
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel){}
            } message: {
                Text(errorMessage)
            }
            .toolbar() {
                Button("Restart", action: restartGame)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isNotTooShort(word: answer, minLength: rootWordMinLength) else {
            wordError(title: "Word is too short", message: "Minimum length of word is \(rootWordMinLength)")
            return
        }
        
        guard isNotTheStartingWord(word: answer) else {
            wordError(title: "Word is identical to the starting word", message: "Really dude?")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Used already", message: "Be more original!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        withAnimation() {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: .newlines)
                rootWord = allWords.randomElement()?.uppercased() ?? "SILKWORM"
                return
            }
        }
        
        fatalError("Could not load required file from bundle")
    }
    
    func restartGame () {
        startGame()
        usedWords.removeAll()
        score = 0
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isNotTooShort(word: String, minLength: Int = 4) -> Bool {
        word.count >= minLength
    }
    
    func isNotTheStartingWord(word: String) -> Bool {
        word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
