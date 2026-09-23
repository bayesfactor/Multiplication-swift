//
//  ContentView.swift
//  TimesTablesSwift
//
//  Created by Tim Holme on 1/3/25.
//  App implements practice for multiplication
//  generates 10 random problems (easy/medium/hard)
//  and asks the user to answer the multiplication problems.
//  checks correctness and, if correct, moves to the next problem
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var userAnswer: String = ""
    @State private var showingWinAlert = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
                    VStack(spacing: 0) {
                        if gameState.showTrophy {
                            Image("trophy1")
                                .resizable()
                                .scaledToFit()
                                .transition(.opacity)
                        } else {
                            ScrollView {
                                VStack {
                                    // Daily points indicator (points scored today / daily target)
                                    HStack {
                                        Spacer()
                                        Text("\(gameState.pointsToday)/\(gameState.dailyTarget)")
                                            .font(.system(size: min(40, geometry.size.width * 0.1)))
                                            .foregroundColor(.blue)
                                    }
                                    .padding([.top, .trailing])
                                    
                                    // Multiplication problem
                                    HStack {
                                        Text("\(gameState.num1)")
                                            .font(.system(size: min(120, geometry.size.width * 0.25)))
                                            .foregroundColor(gameState.color1)
                                        Text("×")
                                            .font(.system(size: min(120, geometry.size.width * 0.25)))
                                            .foregroundColor(gameState.colorX)
                                        Text("\(gameState.num2)")
                                            .font(.system(size: min(120, geometry.size.width * 0.25)))
                                            .foregroundColor(gameState.color2)
                                    }
                                    .padding()
                                    
                                    // Answer display
                                    Text(userAnswer.isEmpty ? "?" : userAnswer)
                                        .font(.system(size: min(80, geometry.size.width * 0.2)))
                                        .frame(height: 80)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding()
                                    
                                    // Feedback label
                                    Text(gameState.feedbackText)
                                        .font(.system(size: min(60, geometry.size.width * 0.15)))
                                        .foregroundColor(gameState.feedbackColor)
                                        .padding(.bottom)
                                    
                                    // Difficulty buttons
                                    HStack {
                                        DifficultyButton(title: "Easy", color: .green) {
                                            gameState.setDifficulty(.easy)
                                        }
                                        DifficultyButton(title: "Medium", color: .orange) {
                                            gameState.setDifficulty(.medium)
                                        }
                                        DifficultyButton(title: "Hard", color: .red) {
                                            gameState.setDifficulty(.hard)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Custom numeric keypad
                            CustomKeypad(input: $userAnswer) {
                                checkAnswer()
                            }
                            .frame(height: geometry.size.height * 0.4)
                        }
                    }
                }
                .alert("Congratulations!", isPresented: $showingWinAlert) {
                    Button("Play Again") {
                        gameState.reset()
                    }
                } message: {
                    Text("You've completed all \(gameState.numQuestions) questions!")
                }
            }
            
    
    private func checkAnswer() {
        guard let answer = Int(userAnswer) else {
            userAnswer = ""
            return
        }
        
        if answer == gameState.num1 * gameState.num2 {
            gameState.numCorrect += 1
            gameState.awardForCorrect()
            gameState.feedbackText = "Correct!"
            gameState.feedbackColor = .green
            
            if gameState.numCorrect >= gameState.numQuestions {
                gameState.showTrophy = true
                showingWinAlert = true
            } else {
                gameState.updateProblem()
            }
        } else {
            gameState.registerWrongAttempt()
            gameState.feedbackText = "Please try again"
            gameState.feedbackColor = .red
        }
        
        userAnswer = ""
    }
}

struct CustomKeypad: View {
    @Binding var input: String
    let onSubmit: () -> Void
    
    let buttons: [[KeypadButton]] = [
        [.number("1"), .number("2"), .number("3")],
        [.number("4"), .number("5"), .number("6")],
        [.number("7"), .number("8"), .number("9")],
        [.delete, .number("0"), .enter]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { button in
                        KeypadButtonView(button: button) {
                            switch button {
                            case .number(let num):
                                if input.count < 4 { // Limit input length
                                    input += num
                                }
                            case .delete:
                                input = String(input.dropLast())
                            case .enter:
                                onSubmit()
                            }
                        }
                    }
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
    }
}

enum KeypadButton: Hashable {
    case number(String)
    case delete
    case enter
}

struct KeypadButtonView: View {
    let button: KeypadButton
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(buttonColor)
                
                buttonContent
                    .foregroundColor(.white)
                    .font(.system(size: 30, weight: .medium))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var buttonContent: some View {
        switch button {
        case .number(let num):
            return Text(num).eraseToAnyView()
        case .delete:
            return Image(systemName: "delete.left").eraseToAnyView()
        case .enter:
            return Image(systemName: "return").eraseToAnyView()
        }
    }
    
    private var buttonColor: Color {
        switch button {
        case .number:
            return Color.blue.opacity(0.8)
        case .delete:
            return Color.red.opacity(0.8)
        case .enter:
            return Color.green.opacity(0.8)
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct DifficultyButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(10)
        }
    }
}

class GameState: ObservableObject {
    @Published var num1: Int = 0
    @Published var num2: Int = 0
    @Published var numCorrect: Int = 0
    @Published var feedbackText: String = " "
    @Published var feedbackColor: Color = .black
    @Published var showTrophy: Bool = false
    @Published var color1: Color = .random
    @Published var color2: Color = .random
    @Published var colorX: Color = .random
    @Published var pointsToday: Int = 0

    let numQuestions = 10
    private var lowerBound = 0
    private var upperBound = 5

    // Per-problem scoring state (accuracy + speed).
    private var problemStartTime = Date()
    private var wrongAttempts = 0

    // Persistence for the daily points total.
    private let pointsKey = "pointsToday"
    private let pointsDateKey = "pointsDate"

    // Point target schedule: 3300 on 2026-09-21, increasing 100 per calendar
    // day thereafter. Dates before the start clamp to 3300.
    var dailyTarget: Int {
        let calendar = Calendar.current
        var start = DateComponents()
        start.year = 2026
        start.month = 9
        start.day = 21
        guard let startDate = calendar.date(from: start) else { return 3300 }
        let startDay = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: startDay, to: today).day ?? 0
        return 3300 + 100 * max(0, days)
    }

    init() {
        loadPoints()
        updateProblem()
    }

    func addPoints(_ amount: Int) {
        loadPoints() // roll over if the day changed since launch
        pointsToday += amount
        savePoints()
    }

    func registerWrongAttempt() {
        wrongAttempts += 1
    }

    // Award points for a correct answer, scaled by speed and accuracy.
    // Speed: 1.0 at <=2s, decaying linearly to 0.2 at >=10s.
    // Accuracy: 1.0 with no wrong attempts, -0.25 each, floored at 0.25.
    func awardForCorrect() {
        let elapsed = Date().timeIntervalSince(problemStartTime)
        let speedFactor = max(0.2, min(1.0, 1.0 - (elapsed - 2.0) / 8.0 * 0.8))
        let accuracyFactor = max(0.25, 1.0 - 0.25 * Double(wrongAttempts))
        let points = max(1, Int((100.0 * speedFactor * accuracyFactor).rounded()))
        addPoints(points)
    }

    private static func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func loadPoints() {
        let defaults = UserDefaults.standard
        let today = GameState.dayString(for: Date())
        if defaults.string(forKey: pointsDateKey) == today {
            pointsToday = defaults.integer(forKey: pointsKey)
        } else {
            pointsToday = 0
            defaults.set(today, forKey: pointsDateKey)
            defaults.set(0, forKey: pointsKey)
        }
    }

    private func savePoints() {
        let defaults = UserDefaults.standard
        defaults.set(GameState.dayString(for: Date()), forKey: pointsDateKey)
        defaults.set(pointsToday, forKey: pointsKey)
    }
    
    func updateProblem() {
        num1 = Int.random(in: lowerBound...upperBound)
        num2 = Int.random(in: lowerBound...upperBound)
        color1 = .random
        color2 = .random
        colorX = .random
        problemStartTime = Date()
        wrongAttempts = 0
        //feedbackText = " "
    }
    
    func reset() {
        numCorrect = 0
        showTrophy = false
        feedbackText = " "
        updateProblem()
    }
    
    func setDifficulty(_ difficulty: Difficulty) {
        switch difficulty {
        case .easy:
            lowerBound = 0
            upperBound = 5
        case .medium:
            lowerBound = 3
            upperBound = 8
        case .hard:
            lowerBound = 3
            upperBound = 12
        }
        //reset()
    }
}

enum Difficulty {
    case easy, medium, hard
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

//@main
struct TimesTablesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
