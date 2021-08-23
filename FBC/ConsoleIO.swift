//
//  ConsoleIO.swift
//  FBC
//
//  Created by Richard Hood on 8/23/21.
//
// console I/O interfaces


import Foundation

enum OutputType {
	case error
	case standard
}

class ConsoleIO {
    
  func writeMessage(_ message: String, to: OutputType = .standard) {
    switch to {
    case .standard:
      // 1
      print("\u{001B}\(message)")
    case .error:
      // 2
      fputs("\u{001B}\(message)\n", stderr)
    }
  }
  
  func getInput() -> String {
    // 1
    let keyboard = FileHandle.standardInput
    // 2
    let inputData = keyboard.availableData
    // 3
    let strData = String(data: inputData, encoding: String.Encoding.utf8)!
    // 4
    return strData.trimmingCharacters(in: CharacterSet.newlines)
  }
}

