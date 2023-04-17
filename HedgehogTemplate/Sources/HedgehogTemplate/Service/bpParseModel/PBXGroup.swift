//
//  PBXGroup.swift
//  
//
//  Created by Даниил Пасилецкий on 15.04.2023.
//

import Foundation

class PBXGroup {
  let uuid: String
  let isa: String
  let path: String?
  let name: String?
  let sourceTree: String
  var children: [PBXGroup]?
  var files: [String]?
  var childrenUUID: [String]

  public var ID: String {
    name ?? path ?? ""
  }

  init(
    uuid: String,
    isa: String = "PBXGroup",
    path: String?,
    name: String? = nil,
    sourceTree: String = "\"<group>\"",
    childrenUUID: [String],
    children: [PBXGroup]? = nil,
    files: [String]? = nil
  ) {
    self.uuid = uuid
    self.isa = isa
    self.path = path
    self.name = name
    self.sourceTree = sourceTree
    self.children = children
    self.files = files
    self.childrenUUID = childrenUUID
  }

  var toString: String {
   var p = ""
    if let path {
      p = "path = \(path);\n"
    } else if let name {
      p = "name = \(name);\n"
    }
return """
    \(uuid) /* \(ID) */ = {
      isa = \(isa);
      children = (
        \(childrenUUID.joined(separator: ",\n"))
      );
      \(p)sourceTree = \(sourceTree);
    };
"""
  }
  init?(parsLine: String) {
    let line = parsLine.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      let uuid = line.split(separator: " ")[safe: 0],
      let isa = line.findFirst(pattern: "isa = (.+?);"),
      let sourceTree = line.findFirst(pattern: "sourceTree = (.+?);"),
      let childText = line.findFirst(pattern: "children = \\((.+?)\\);")
    else {
      return nil
    }
    let children = childText.split(separator: ",").compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")[safe: 0] }
    childrenUUID = children.map { String($0) }
    self.isa = isa
    self.uuid = String(uuid)
    self.sourceTree = sourceTree
    self.name = line.findFirst(pattern: "name = (.+?);")
    self.path = line.findFirst(pattern: "path = (.+?);")
  }

  static func parseSection(lines: [String]) -> [PBXGroup] {
    let text = lines.joined()
    let components = text.find(pattern: ".+? = {.+?};")
    let array = components.compactMap { PBXGroup(parsLine: $0) }

    return array
  }


}
