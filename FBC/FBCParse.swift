//
//  FBCParse.swift
//  FBC
//
//  Created by Richard Hood on 8/23/21.
//
// parse input equation strings and format output string

import Foundation

enum EquationErrors: String, Codable {
    case kNoError = "No error"
    case kEquationParseError = "Error parsing equation"
    case kNumberParseError = "Error parsing number"
    case kNumberOverflowError = "Number overflow error"
}

class FBCParse {
    
    // parse the components of the inputted equation
    // Note: Only one operation is processed per equation.
    // Otherwise the program would have to deal with precedence of operations,
    // (i.e. multiply and divide over add and subtract) which is does not.
    func parseEquation(_ inputString: String) -> (EquationErrors, Double, Double, String) {
        
        var operand1String = ""
        var operand2String = ""
        var operatorString = ""
        let tokens = inputString.components(separatedBy: " ")
        for token in tokens {
            if !(token.isEmpty) {
                if operand1String.isEmpty {
                    operand1String = token
                }
                else if operatorString.isEmpty {
                    operatorString = token
                }
                else if operand2String.isEmpty {
                    operand2String = token
                }
                else {
                    return (.kEquationParseError, 0, 0, "")
                }
            }
        }
        
        if operatorString != "+" && operatorString != "-" &&
            operatorString != "*" && operatorString != "/" {
            return (.kEquationParseError, 0, 0, "")
        }
        
        let result1 = decodeNumber(operand1String)
        if result1.0 != .kNoError {
            return (result1.0, 0, 0, "")
        }
        let operand1 = result1.1
        
        let result2 = decodeNumber(operand2String)
        if result2.0 != .kNoError {
            return (result2.0, 0, 0, "")
        }
        let operand2 = result2.1
        
        return (.kNoError, operand1, operand2, operatorString)
    }
    
    // parse the inputted formatted number to Double with error checking
    // convert string of the format N_n/d to double where:
    // - N_ is optional if N is zero
    // - _n/d is optional if fraction is zero
    // encoded string can be proceeded by - if it is negative
    func decodeNumber(_ numberString: String) -> (EquationErrors, Double) {
        
        var localString = numberString
        var isNegative = false
        if numberString.first == "-" {
            isNegative = true
            localString = String(numberString.dropFirst())
        } else if numberString.first == "+" {
            localString = String(numberString.dropFirst())
        }

        let nrUnderbar = localString.count(ofCharacter: "_")
        let nrSlash = localString.count(ofCharacter: "/")
        if nrUnderbar > 1 || nrSlash > 1 {
            return (.kNumberParseError, 0)
        }
        
        var integerNumber = 0
        var fractionNumber = 0.0
        if nrUnderbar == 0 && nrSlash == 0 {
            // integer number with no fraction
            if localString.isNumeric() {
                if let int = Int(localString) {
                    integerNumber = int
                }
                else {
                    return (.kNumberOverflowError, 0)
                }
            }
            else {
                return (.kNumberParseError, 0)
            }
        } else if nrUnderbar == 0 && nrSlash == 1 {
            // fraction with 0 integer
            let result = decodeFraction(localString)
            if result.0 != .kNoError {
                return (result.0, 0)
            }
            fractionNumber = result.1
        } else {
            // number with both integer and fractional parts
            let parts = localString.components(separatedBy: "_")
            if parts.count != 2 {
                return (.kNumberParseError, 0)
            }
            let integerString = parts[0]
            if integerString.isNumeric() {
                if let int = Int(integerString) {
                    integerNumber = int
                }
                else {
                    return (.kNumberOverflowError, 0)
                }
            }
            else {
                return (.kNumberParseError, 0)
            }
            let fractionString = parts[1]
            let result = decodeFraction(fractionString)
            if result.0 != .kNoError {
                return (result.0, 0)
            }
            fractionNumber = result.1
        }
        
        let result = Double(integerNumber) + fractionNumber
        return (.kNoError, (isNegative ? -result : result))
    }
    
    // format inputted double to sormatted string
    // convert double to N_n/d string where:
    // - N_ is optional if N is zero
    // - _n/d is optional if fraction is zero
    // encoded string is proceeded by - if it is negative
    func encodeNumber(_ value: Double) -> String {

        let isNegative = (value < 0) ? true : false
        let localValue = isNegative ? -value : value
        let fractionNumber = localValue.truncatingRemainder(dividingBy: 1)
        let integerNumber = Int(floor(localValue))

        let integerString = isNegative ? "-" + String(integerNumber) : String(integerNumber)
        if fractionNumber == 0 {
            return integerString
        }
        
        let fractionString = encodeFraction(fractionNumber)

        return integerString + "_" + fractionString
    }
    
    // parse the inputted formatted fraction to Double with error checking
    // convert n/d string to double
    func decodeFraction(_ fractionString: String) -> (EquationErrors, Double) {

        let parts = fractionString.components(separatedBy: "/")
        if parts.count != 2 {
            return (.kNumberParseError, 0)
        }
        let numeratorString = parts[0]
        let denominatorString = parts[1]
        if !(numeratorString.isNumeric()) || !(denominatorString.isNumeric()) {
            return (.kNumberParseError, 0)
        }
        guard let numerator = Double(numeratorString) else {
            return (.kNumberOverflowError, 0)
        }
        guard let denominator = Double(denominatorString) else {
            return (.kNumberOverflowError, 0)
        }
        if denominator == 0 {
            return (.kNumberParseError, 0)
        }
        let fraction = numerator / denominator
        return (.kNoError, fraction)
    }
    
    // format real double to fraction string
    // convert double fraction to n/d string
    func encodeFraction(_ value: Double) -> String {

        let results = rationalApproximation(of: value)
        
        return String(results.0) + "/" + String(results.1)
    }
    
    // compute greatest common denominator
    func gcd(_ op1: Int, _ op2: Int) -> Int {
        let remainder = abs(op1) % abs(op2)
        if remainder != 0 {
            return gcd(abs(op2), remainder)
        } else {
            return abs(op2)
        }
    }

    // grabbed from StackOverflow because rational to fractions is a nontrivial problem
    // due to repeating decimals
    // https://stackoverflow.com/questions/35895154/decimal-to-fraction-conversion-in-swift
    func rationalApproximation(of x0 : Double, withPrecision eps : Double = 1.0E-6) -> (Int, Int) {
        var x = x0
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)

        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }

}
