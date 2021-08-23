//
//  StringExtensions.swift
//  FBC
//
//  Created by Richard Hood on 8/23/21.
//
// Helper functions for extend String class


import Foundation


extension String {
    
    func count(ofCharacter ch: Character) -> Int {
        let cnt = self.filter { $0 == ch }.count
        return cnt
    }
    
    func isNumeric() -> Bool {
        guard !(self.isEmpty) else { return false }

        let numericCharacters = CharacterSet.decimalDigits.inverted
        return (self.rangeOfCharacter(from: numericCharacters) == nil)
    }

}
