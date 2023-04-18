//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 18.04.2023.
//

import Foundation

class SwiftFile {
  var elements: [Element]

  init(text: String) {
    var text2 = text.split(separator: " ").joined(separator: " ")
    elements = parse(inpoutText: text2)

    func parse(inpoutText: String) -> [Element] {
      var res: [Element] = []
      var text = inpoutText.trimmingCharacters(in: .whitespacesAndNewlines)

      while !text.isEmpty {
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if text.hasPrefix("//") {
          if text.hasPrefix("//\n") {
            let com = Comment(type: .oneLine, text: "")
            res.append(com)
            text = text.deletingPrefix("//\n")
          } else if let c = text.findFirst(pattern: "\\/\\/(.+?)\\n") {
            let com = Comment(type: .oneLine, text: c.1)
            res.append(com)
            text = text.deletingPrefix(c.0)
          }
        } else if text.hasPrefix("/*") {
          if let c = text.findFirst(pattern: "\\/\\*(.+?)\\*\\/") {
            let com = Comment(type: .oneLine, text: c.1)
            res.append(com)
            text = text.deletingPrefix(c.0)
          }
        } else if text.hasPrefix("import") {
          if let im = text.findFirst(pattern: "import (.+?)\\n") {
            res.append(Import(module: im.1))
            text = text.deletingPrefix(im.0)
          }
        } else if text.hasPrefix("\n") {
          res.append(EmptyLine())
          text = text.deletingPrefix("\n")
        } else if text.hasPrefix("struct") {
          var startProtocol = 0
          var count = 0
          var start = 0
          var end = 0
          for (i, element) in text.enumerated() {
            if element == ":", startProtocol == 0 {
              startProtocol = i + 1
            }
            if element == "{" {
              if count == 0 {
                start = i + 1
              }
              count += 1
            } else if element == "}" {
              count -= 1
            }
            if count == 0, start != 0 {
              end = i - 1
              break
            }
          }

          let name = String(text.split(separator: " ")[1])
          var protocols: [String] = ["sdsd"]
          if startProtocol != 0 {
            protocols = String(text[startProtocol...start]).split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
          }
          let subText = String(text[start...end])

          let model = StructSwift(name: name, elements: parse(inpoutText: subText), protocols: protocols)

          res.append(model)
          text = String(text.dropFirst(end))
        } else if let prefi = text.findPrefix(PropertiSwift.allprefix()) {
          let split = text.split(separator: " ")
          var index = split.firstIndex(of: "=")
          var i = index! + 1
          var current = String(split[i])

          current = current.replacingOccurrences(of: " ", with: "")
          current = current.replacingOccurrences(of: "\n", with: "")
          while current.isEmpty {
            current = String(split[i])
            current = current.replacingOccurrences(of: " ", with: "")
            current = current.replacingOccurrences(of: "\n", with: "")
            i += 1
          }
          var j = i
          if current.contains("[") {
            while !current.contains("]") {
              current = String(split[j])
              j += 1
            }
            let arr = split[i..<j]
            let s = PropertiSwift(prefix: prefi, value: arr.joined(separator: " "))
            res.append(s)
            text = split[j...].joined(separator: " ")
          } else {
            let s = PropertiSwift(prefix: prefi, value: current)
            res.append(s)
            text = split[(i+1)...].joined(separator: " ")
          }
        } else {
          if let line = text.findFirst(pattern: "(.+?)\\n") {
            res.append(Code(value: line.1))
            text = text.deletingPrefix(line.0)
          } else {
            res.append(Code(value: text))
            text = ""
          }
        }
      }
      return res
    }
  }


  func decod() -> String {
    self.elements.map { $0.decoding() }.joined(separator: "\n")
  }

}

extension String {

  func findFirst(pattern: String) -> (String, String)? {
    guard let reg = try? Regex(pattern).dotMatchesNewlines() else { return  nil }
    guard
      let a = self.firstMatch(of: reg),
      a.count > 1,
      let str = a.output[1].substring,
      let pat = a.output[0].substring
    else { return  nil }
    return (String(pat), String(str))
  }

  func find(pattern: String) -> [String] {
    guard let reg = try? Regex(pattern) else { return  [] }
    let a = self.matches(of: reg)
    let res = a.compactMap { $0.output[0].substring }
    return res.map { String($0) }
  }


}

extension String {
  func deletingPrefix(_ prefix: String) -> String {
    guard self.hasPrefix(prefix) else { return self }
    return String(self.dropFirst(prefix.count))
  }

  func findPrefix(_ prefix: [String]) -> String? {

    for line in prefix {
      if self.hasPrefix(line) {
        return line
      }
    }
    return nil
  }
}
