//
//  Element.swift
//  
//
//  Created by Даниил Пасилецкий on 18.04.2023.
//

protocol Element {
  func decoding() -> String 
}

class Import: Element {
  let module: String

  func decoding() -> String {
    "import \(module)"
  }

  init(module: String) {
    self.module = module
  }
}

class EmptyLine: Element {
  func decoding() -> String {
    "\n"
  }
}

class StructSwift: Element {
  internal init(name: String, elements: [Element], protocols: [String]) {
    self.name = name
    self.elements = elements
    self.protocols = protocols
  }

  func decoding() -> String {
    "struct \(name): \(protocols.joined(separator: ", ")){/n\((elements.map { "  " + $0.decoding() }).joined(separator: "\n"))}"
  }

  let name: String
  let elements: [Element]
  let protocols: [String]
}

class Code: Element {
  var value: String
  init(value: String) {
    self.value = value
  }
  func decoding() -> String {
    value
  }
}

class PropertiSwift: Element {
  internal init(prefix: String, value: String) {
    self.prefix = prefix
    self.value = value

  }

  static func allprefix() -> [String] {
    var a: [String] = []
    for modificator in ["private", "public", "internal", ""] {
      for atributte in ["weak", "lazy",""] {
        for type in ["let", "var" ] {
          let line = "\(modificator) \(atributte) \(type)"
          a.append(line.split(separator: " ").joined(separator: " "))
        }
      }
    }
    return a
  }
  
  func decoding() -> String {
    "\(self.prefix) = \(value)"
  }

  let prefix: String
  let value: String

}
