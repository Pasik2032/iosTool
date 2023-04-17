//
//  PBXFileReference.swift
//  
//
//  Created by Даниил Пасилецкий on 15.04.2023.
//

struct PBXFileReference {
  let uuid: String
  let isa: String
  let lastKnownFileType: String
  let path: String
  let sourceTree: String
  let name: String
  let nameField: String?

  init(
    uuid: String,
    name: String,
    isa: String = "PBXFileReference",
    lastKnownFileType: String = "sourcecode.swift",
    path: String,
    sourceTree: String = "\"<group>\"",
    nameField: String? = nil
  ) {
    self.name = name
    self.uuid = uuid
    self.isa = isa
    self.lastKnownFileType = lastKnownFileType
    self.path = path
    self.sourceTree = sourceTree
    self.nameField = nameField
  }

  static func parseSection(text: [String]) -> [PBXFileReference] {
    text.compactMap { PBXFileReference(parseLine: $0) }
  }

  var toString: String {
    if let nameField {
      return "\(uuid) /* \(name) */ = {isa = \(isa); lastKnownFileType = \(lastKnownFileType); name = \(nameField); path = \(path); sourceTree = \(sourceTree); };"
    } else {
      return "\(uuid) /* \(name) */ = {isa = \(isa); lastKnownFileType = \(lastKnownFileType); path = \(path); sourceTree = \(sourceTree); };"
    }
  }

  init?(parseLine: String) {
    let line = parseLine.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      let uuid = line.split(separator: " ")[safe: 0],
      let isa = line.findFirst(pattern: "isa = (.+?);"),
      let lastKnownFileType = line.findFirst(pattern: "lastKnownFileType = (.+?);"),
      let path = line.findFirst(pattern: "path = (.+?);"),
      let sourceTree = line.findFirst(pattern: "sourceTree = (.+?); "),
      let name = line.findFirst(pattern: "\\/\\* ([^ ]+) \\*\\/")
    else {
      return nil
    }

    let nameField = line.findFirst(pattern: "name = (.+?);")
    self.init(
      uuid: String(uuid),
      name: name,
      isa: isa,
      lastKnownFileType: lastKnownFileType,
      path: path,
      sourceTree: sourceTree,
      nameField: nameField
    )
  }
}
