//
//  String+Regex.swift
//  
//
//  Created by Даниил Пасилецкий on 15.04.2023.
//

import Foundation

extension String {

  func findFirst(pattern: String) -> String? {
    guard let reg = try? Regex(pattern) else { return  nil }
    guard
      let a = self.firstMatch(of: reg),
      a.count > 1,
      let str = a.output[1].substring
    else { return  nil }
    return String(str)
  }

  func find(pattern: String) -> [String] {
    guard let reg = try? Regex(pattern) else { return  [] }
    let a = self.matches(of: reg)
    let res = a.compactMap { $0.output[0].substring }
    return res.map { String($0) }
  }



  func matches(for regex: String) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let results = regex.matches(
        in: self,
        range: NSRange(self.startIndex..., in: self)
      )
      return results.map {
        String(self[Range($0.range, in: self)!])
      }
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }
}

extension String {
  func deletingPrefix(_ prefix: String) -> String {
    guard self.hasPrefix(prefix) else { return self }
    return String(self.dropFirst(prefix.count))
  }
}


extension String {
  func chopPrefix(_ count: Int = 1) -> String {
    return substring(from: index(startIndex, offsetBy: count))
  }

  func chopSuffix(_ count: Int = 1) -> String {
    return substring(to: index(endIndex, offsetBy: -count))
  }
}
