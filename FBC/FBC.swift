//
//  FBC.swift
//  FBC
//
//  Created by Richard Hood on 8/23/21.
//
// I/O interface between CLI tool console input and equation calc class

import Foundation

class FBC {

    let consoleIO = ConsoleIO()
    private let parser = FBCParse()

    func inputMode() {

        consoleIO.writeMessage("\n  Enter an equation. Enter q to quit.\n")

        var doQuit = false
        while !doQuit {

            let value = consoleIO.getInput()
            if value == "q" || value == "quit" {
                doQuit = true
            }
            else {
                let results = parser.parseEquation(value)
                let error = results.0
                if error != .kNoError {
                    consoleIO.writeMessage("\n  " + error.rawValue)
                }
                else {
                    let operand1 = results.1
                    let operand2 = results.2
                    let operatorString = results.3
                    
                    switch operatorString {
                    case "+":
                        let answer = operand1 + operand2
                        let answerString = parser.encodeNumber(answer)
                        consoleIO.writeMessage("\n  = " + answerString)
                    case "-":
                        let answer = operand1 - operand2
                        let answerString = parser.encodeNumber(answer)
                        consoleIO.writeMessage("\n  = " + answerString)
                    case "*":
                        let answer = operand1 * operand2
                        let answerString = parser.encodeNumber(answer)
                        consoleIO.writeMessage("\n  = " + answerString)
                    case "/":
                        if operand2 == 0 {
                            consoleIO.writeMessage("\n  " + EquationErrors.kDivideByZeroError.rawValue)
                        } else {
                            let answer = operand1 / operand2
                            let answerString = parser.encodeNumber(answer)
                            consoleIO.writeMessage("\n  = " + answerString)
                        }
                    default:
                        consoleIO.writeMessage("\n  " + EquationErrors.kEquationParseError.rawValue)
                    }
                }
            }
        }
    }
    
}

