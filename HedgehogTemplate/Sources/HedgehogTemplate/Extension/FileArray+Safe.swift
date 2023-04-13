//
//  Array+Safe.swift
//  
//
//  Created by Даниил Пасилецкий on 13.04.2023.
//

import Foundation

public extension Array {
  subscript (safe index: Int) -> Element? {
    return indices ~= index ? self[index] : nil
  }

  subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
    if bounds.lowerBound > count { return [] }
    let lower = Swift.max(0, bounds.lowerBound)
    let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
    return self[lower..<upper]
  }

  subscript(safe lower: Int?, _ upper: Int?) -> ArraySlice<Element> {
    let lower = lower ?? 0
    let upper = upper ?? count
    if lower > upper { return [] }
    return self[safe: lower..<upper]
  }

  mutating func move(from oldIndex: Index, to newIndex: Index) {
    if oldIndex == newIndex { return }
    if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
    self.insert(self.remove(at: oldIndex), at: newIndex)
  }
}
