//
//  PBXSourcesBuildPhase.swift
//  
//
//  Created by Даниил Пасилецкий on 16.04.2023.
//

import Foundation

struct PBXSourcesBuildPhase {
  let uuid: String
  let isa: String
  let buildActionMask: String
  let files: [String]
  let runOnlyForDeploymentPostprocessing: String

  init?(parseLine: String) {
    let line = parseLine.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      let uuid = line.split(separator: " ")[safe: 0],
      let isa = line.findFirst(pattern: "isa = (.+?);"),
      let buildActionMask = line.findFirst(pattern: "buildActionMask = (.+?);"),
      let runOnlyForDeploymentPostprocessing = line.findFirst(pattern: "runOnlyForDeploymentPostprocessing = (.+?);"),
      let filesStr = line.findFirst(pattern: "files = \\((.+?)\\);")
    else {
      return nil
    }

    let file = filesStr.split(separator: ",").compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")[safe: 0] }
    self.uuid = String(uuid)
    self.isa = isa
    self.buildActionMask = buildActionMask
    self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
    self.files = file.map { String($0) }
  }

  static func parseSection(lines: [String]) -> [PBXSourcesBuildPhase] {
    let text = lines.joined()
    let components = text.find(pattern: ".+? = {.+?};")
    let array = components.compactMap { PBXSourcesBuildPhase(parseLine: $0) }

    return array
  }
}
