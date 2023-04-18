import Files

class HedgehogMerge {

  private let arguments: [String]
  
  public init?(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  func run() {

    let folder = Folder.current
    guard
      let project = seachProject(folder: folder),
      let bdprofect = project.files.first(where: { $0.extension ==  "pbxproj" }),
      let bdProfectString = try? bdprofect.readAsString()
    else {
      print("Произошла ошибка, Проджект файл не найден")
      return
    }

    var lines = bdProfectString.components(separatedBy: "\n")
    let v = sechConflict(lines: lines)

    let version = v.0 + ";"
    let build = v.1 + ";"


    var i = 0
    while i < lines.count {
      if
        lines[i].contains("<<<<<<<"),
        (lines[i+1].contains("MARKETING_VERSION") || lines[i+1].contains("CURRENT_PROJECT_VERSION")),
        lines[i+2].contains("======="),
        (lines[i+3].contains("MARKETING_VERSION") || lines[i+3].contains("CURRENT_PROJECT_VERSION")),
        lines[i+4].contains(">>>>>>>")
      {
        if lines[i+1].contains("MARKETING_VERSION") {
          let arr = lines[i+1].split(separator: " ")
          lines[i+1].replace(arr[2], with: version)
        } else {
          let arr = lines[i+1].split(separator: " ")
          lines[i+1].replace(arr[2], with: build)
        }
        lines.remove(at: i+4)
        lines.remove(at: i+3)
        lines.remove(at: i+2)
        lines.remove(at: i)

      }
      i += 1
    }

    try? bdprofect.write(lines.joined(separator: "\n"))
  }


  private func sechConflict(lines: [String]) -> (String, String) {
    var i = 0
    var v1 = ""
    var v2 = ""
    var build1 = ""
    var build2 = ""
    while i < lines.count {
      if lines[i].contains("<<<<<<<"),
        (lines[i+1].contains("MARKETING_VERSION") || lines[i+1].contains("CURRENT_PROJECT_VERSION")),
        lines[i+2].contains("======="),
        (lines[i+3].contains("MARKETING_VERSION") || lines[i+3].contains("CURRENT_PROJECT_VERSION")),
        lines[i+4].contains(">>>>>>>") {
        if lines[i+1].contains("MARKETING_VERSION") {
          v1 = String(lines[i+1].split(separator: " ")[2])
          v2 = String(lines[i+3].split(separator: " ")[2])
        } else {
          build1 = String(lines[i+1].split(separator: " ")[2])
          build2 = String(lines[i+3].split(separator: " ")[2])
        }
      }
      i += 1
    }
    print("Обнаружен конфликт в версиях \(v1) \(build1) и \(v2) \(build2)")
    let line = readLine()?.split(separator: " ")
    return (String(line![0]), String(line![1]))
  }


  private func seachProject(folder: Folder) -> Folder? {
    let folders = folder.subfolders.first { $0.extension ==  "xcodeproj" }

    if let folders {
      return folders
    }

    if let parent = folder.parent {
      return seachProject(folder: parent)
    } else {
      return nil
    }
  }

}
