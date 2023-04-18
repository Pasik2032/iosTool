//
//  Comment.swift
//  
//
//  Created by Даниил Пасилецкий on 18.04.2023.
//

import Foundation

class Comment: Element {
  func decoding() -> String {
    switch type {
    case .oneLine: return "// \(text)"
    case .multyLine: return "/*\n\(text)\n*/"
    }
  }

  let type: TypeComment
  let text: String

  init(
    type: TypeComment,
    text: String
  ) {
    self.type = type
    self.text = text
  }

  static let startSymbols = [ "//", "/*"]

  enum TypeComment {
    case oneLine
    case multyLine
  }
}
