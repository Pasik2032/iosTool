//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 06.04.2023.
//

import Foundation

class CodeStyleFormatter {
  let rules: Rules

  init(rules: Rules) {
    self.rules = rules
  }

  func formatter(_ code: String) -> String {
    var currenLine: Int = 0
    var nextLine: Int = 0
    var counterBrace: [(Character, Bool)] = []
    var lines = code.components(separatedBy: "\n")
    for j in 0..<lines.count {
      if !lines[j].isEmpty, lines[j][0] == "/" {
        continue
      }
      lines[j] = lines[j].trimmingCharacters(in: .whitespaces)
      let line = lines[j]
      for i in 0..<line.count {
        if line[i] == "{", i-1 >= 0, line[i-1] != " " {
          let index = line.index(line.startIndex, offsetBy: i)
          lines[j].insert(" ", at: index)
        }
        if ["{", "[", "("].contains(line[i]) {
          var flag = true
          if i+1 < line.count {
            for k in (i+1)..<line.count {
              if line[k] != " ", line[k] != "\n" {
                flag = false
                break
              }
            }
          }
          nextLine += flag ? 2 : 0
          counterBrace.append((line[i], flag))
        }
        
        if ["}", "]", ")"].contains(line[i]) {
          var flag = true
          if i > 0 {
            for k in 1...i {
              let l = i - k
              if line[l] != " ",  !["}", "]", ")"].contains(line[l])  {
                flag = false
                break
              }
            }
          }
          currenLine -= flag ? 2 : 0
          nextLine -= flag ? 2 : 0
          counterBrace.removeLast()
        }
      }
      if !lines[j].isEmpty {
        lines[j] = String(repeating: " ", count: currenLine) + lines[j]
      }
      currenLine = nextLine
    }
    return lines.joined(separator: "\n")
  }
}


extension StringProtocol {
  subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
  subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
  subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
  subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
  subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
  subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}

extension LosslessStringConvertible {
  var string: String { .init(self) }
}

extension BidirectionalCollection {
  subscript(safe offset: Int) -> Element? {
    guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
    return self[i]
  }
}
