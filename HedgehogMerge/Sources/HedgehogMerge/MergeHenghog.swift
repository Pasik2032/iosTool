import Files

class HedgehogMerge {

  private let arguments: [String]
  
  public init?(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  func run() {

//    let folder = Folder.current
    let folder = try! Folder(path: arguments[3])
    guard
      arguments.count > 2,
      let project = seachProject(folder: folder),
      let bdprofect = project.files.first(where: { $0.extension ==  "pbxproj" }),
      let bdProfectString = try? bdprofect.readAsString()
    else {
      print("Произошла ошибка, Проджект файл не найден")
      return
    }

    let version: String = arguments[1] + ";"
    let build: String = arguments[2] + ";"


    var lines = bdProfectString.components(separatedBy: "\n")


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
