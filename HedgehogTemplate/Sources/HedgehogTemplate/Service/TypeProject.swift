//
//  TypeProject.swift
//  
//
//  Created by Даниил Пасилецкий on 13.04.2023.
//

import Foundation
import Files

enum TypeProject {
  case project(bpFile: File)
  case package

  init?(folder: Folder) {
    func seach(folder: Folder) -> TypeProject? {
      let project = folder.subfolders.first { $0.extension == "xcodeproj" }
      let package = folder.files.first { $0.name == "Package.swift" }

      if let project, let bp = project.files.first(where: { $0.extension == "pbxproj" }) {
        return .project(bpFile: bp)
      }

      if package != nil {
        return .package
      }

      if let parent = folder.parent {
        return seach(folder: parent)
      } else {
        return nil
      }
    }

    if let type = seach(folder: folder) {
      self  = type
    } else {
      return nil
    }
  }
}
