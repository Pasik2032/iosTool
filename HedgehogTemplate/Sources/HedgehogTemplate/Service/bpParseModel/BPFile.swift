//
//  BPFile.swift
//  
//
//  Created by Даниил Пасилецкий on 15.04.2023.
//

import Foundation
import Files

struct BPFile {
  var files: [PBXBuildFile]
  var reference: [PBXFileReference]
  var groups: [PBXGroup]
//  var buildPhase: [PBXSourcesBuildPhase]
  private var PBXBuildFileSection: (start: Int, end: Int)
  private var PBXFileReferenceSection: (start: Int, end: Int)
  private var PBXSourcesBuildPhaseSection: (start: Int, end: Int)
  private var PBXGroupSection: (start: Int, end: Int)
  private var lines: [String]
  private var mainGroup: String?
  var root: PBXGroup?

  init?(file: File) {
    guard let str = try? file.readAsString() else { return nil }
    self.init(text: str)
  }

  init(text: String) {
    let lines = text.components(separatedBy: "\n")
    self.lines = lines
    var PBXBuildFileSection: (start: Int, end: Int) = (start: 0, end: 0)
    var PBXFileReferenceSection: (start: Int, end: Int) = (start: 0, end: 0)
    var PBXGroupSection: (start: Int, end: Int) = (start: 0, end: 0)
    var PBXSourcesBuildPhaseSection: (start: Int, end: Int) = (start: 0, end: 0)
    for (index, line) in lines.enumerated() {
      if line.contains("Begin PBXBuildFile section") {
        PBXBuildFileSection = (start: index + 1, end: index)
      }

      if line.contains("End PBXBuildFile section") {
        PBXBuildFileSection.end = index - 1
      }

      if line.contains("Begin PBXFileReference section") {
        PBXFileReferenceSection = (start: index + 2, end: index)
      }

      if line.contains("End PBXFileReference section") {
        PBXFileReferenceSection.end = index - 1
      }

      if line.contains("Begin PBXGroup section") {
        PBXGroupSection = (start: index + 1, end: index)
      }

      if line.contains("End PBXGroup section") {
        PBXGroupSection.end = index - 1
      }


//      if line.contains("End PBXSourcesBuildPhase section") {
//        PBXSourcesBuildPhaseSection.end = index - 1
//      }
//
//
//      if line.contains("Begin PBXSourcesBuildPhase section") {
//        PBXSourcesBuildPhaseSection = (start: index + 1, end: index)
//      }

      if line.contains("mainGroup") {
        mainGroup = line.findFirst(pattern: "mainGroup = (.+?);")
      }
    }
    self.files = PBXBuildFile.parseSection(text: Array(lines[PBXBuildFileSection.start...PBXBuildFileSection.end]))
    self.reference = PBXFileReference.parseSection(text: Array(lines[PBXFileReferenceSection.start...PBXFileReferenceSection.end]))
    self.groups = PBXGroup.parseSection(lines: Array(lines[PBXGroupSection.start...PBXGroupSection.end]))
//    self.buildPhase = PBXSourcesBuildPhase.parseSection(lines: Array(lines[PBXSourcesBuildPhaseSection.start...PBXSourcesBuildPhaseSection.end]))
    self.PBXBuildFileSection = PBXBuildFileSection
    self.PBXFileReferenceSection = PBXFileReferenceSection
    self.PBXSourcesBuildPhaseSection = PBXSourcesBuildPhaseSection
    self.PBXGroupSection = PBXGroupSection
    self.root = buldTree()
  }

  mutating func addTempete(files: [File], folder: [Folder], group: PBXGroup) {
    var allFiles: [File] = files
    folder.forEach {
      allFiles += seahFiles(folder: $0)
    }

    let fil: [(File, PBXBuildFile)] = allFiles.map {
      let uuid1 = BPFile.getUUID()
      let uuid2 = BPFile.getUUID()
      let file = PBXBuildFile(uuid: uuid1, fileRef: uuid2, name: $0.name)
      self.files.append(file)
      self.reference.append(PBXFileReference(uuid: uuid2, name: $0.name, path: $0.name))
      return ($0, file)
    }

    files.forEach { a in
      if let file = fil.first(where: { $0.0 == a })?.1 {
        group.childrenUUID.append(file.fileRef)
      }
    }

    func rec(folder: Folder, group: PBXGroup) {
      let groups = folder.subfolders.map { folder in
        let uuid = BPFile.getUUID()
        let group = PBXGroup(uuid: uuid, path: folder.name, childrenUUID: [])
        self.groups.append(group)
        rec(folder: folder, group: group)
        return group
      }

      let child = folder.files.compactMap { f in
        let a = fil.first(where: { $0.0 == f })?.1
        return a?.fileRef
      }
      group.childrenUUID += child
      group.childrenUUID += groups.map { $0.uuid }
      if group.children == nil {
        group.children = []
      }
      group.children! += groups
    }

    let groups = folder.map { folder in
      let uuid = BPFile.getUUID()
      let group = PBXGroup(uuid: uuid, path: folder.name, childrenUUID: [])
      self.groups.append(group)
      rec(folder: folder, group: group)
      return group
    }

    group.childrenUUID += groups.map { $0.uuid }
    group.children! += groups
  }

  static private func getUUID() -> String {
    var gen = HedgehogTemplate.run("uuidgen")
    gen?.replace("-", with: "")
    let shortString = String(gen?.prefix(24) ?? "")
    return shortString
  }

  private func seahFiles(folder: Folder) -> [File] {
    var allFiles: [File] = Array(folder.files)
    folder.subfolders.forEach {
      allFiles += seahFiles(folder: $0)
    }
    return allFiles
  }

  private func buldTree() -> PBXGroup? {
    guard
      let uuid = mainGroup,
      let root = seachGroup(uuid: uuid)
    else {
      return nil
    }

    buldTree(group: root)

    return root
  }

  //
  func findGroup(for path: [String]) -> PBXGroup? {
    var current: PBXGroup? = root
    var index: Int = 0
    while current != nil && index < path.count {
      current = current?.children?.first { $0.ID == path[index] }
      index += 1
    }

    return current
  }

  private func buldTree(group: PBXGroup) {
    group.children = []
    group.childrenUUID.forEach {
      if let findGroup = seachGroup(uuid: $0) {
        group.children?.append(findGroup)
        buldTree(group: findGroup)
      }
    }
  }

  func seachGroup(uuid: String) -> PBXGroup? {
    self.groups.first { $0.uuid == uuid }
  }

  func configText() -> String {
    var text = ""

    var i = 0
    while i < lines.count {
      switch i {
      case PBXBuildFileSection.start:
        text += files.map { $0.toString }.joined(separator: "\n")
        text += "\n"
        i =  PBXBuildFileSection.end
      case PBXFileReferenceSection.start:
        text += reference.map { $0.toString }.joined(separator: "\n")
        i = PBXFileReferenceSection.end
        text += "\n"
      case PBXGroupSection.start:
        text += groups.map { $0.toString }.joined(separator: "\n")
        i = PBXGroupSection.end
        text += "\n"
      default:
        text += lines[i] + "\n"
      }
      i += 1
    }

    return text
  }
}
