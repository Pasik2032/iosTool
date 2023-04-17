//
//  PBXBuildFile.swift
//  
//
//  Created by Даниил Пасилецкий on 15.04.2023.
//

import Foundation

struct PBXBuildFile {
  let uuid: String
  let isa: String
  let fileRef: String
  let name: String

  init(
    uuid: String,
    isa: String = "PBXBuildFile",
    fileRef: String,
    name: String
  ) {
    self.uuid = uuid
    self.isa = isa
    self.fileRef = fileRef
    self.name = name
  }

  var toString: String {
    "\(uuid) /* \(name) in Sources */ = {isa = \(isa); fileRef = \(fileRef) /* \(name) */; };"
  }

  init?(parseLine: String) {
    let line = parseLine.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      let uuid = line.split(separator: " ")[safe: 0],
      let isa = line.findFirst(pattern: "isa = (.+?);"),
      let fileRef = line.findFirst(pattern: "fileRef = (.+?) "),
      let name = line.findFirst(pattern: "\\/\\* ([^ ]+) \\*\\/")
    else {
      return nil
    }

    self.init(uuid: String(uuid), isa: isa, fileRef: fileRef, name: name)
  }

  static func parseSection(text: [String]) -> [PBXBuildFile] {
    text.compactMap { PBXBuildFile(parseLine: $0) }
  }
}
