import Files
import Foundation

public final class CommandLineTool {
  private let arguments: [String]

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  public func run() throws {
    let target = getTarget()
    if let target {
      if let rules = getRules(target) {
        let format = CodeStyleFormatter(rules: rules)
        switch target {
        case .file(let file):
          if let str = try? String(contentsOf: file.url, encoding: .utf8) {
            let filesData = format.formatter(str)
            try file.write(filesData, encoding: .utf8)
          }
        case .directory(let folder):
          allFileFolder(folder: folder).forEach {
            if let str = try? String(contentsOf: $0.url, encoding: .utf8) {
              format.formatter(str)
            }
          }
        }
      } else {
        print("Нам не удалось найти ни одного файла с описанием правил Code style")
        createRules()
      }
    } else {
      print("ERRORR")
    }
  }
  private func allFileFolder(folder: Folder) -> [File] {
    var files: [File] = folder.files.filter { $0.extension == "swift" }

    folder.subfolders.forEach {
      files += allFileFolder(folder: $0)
    }

    return files
  }

  private func createRules() {
    print("Давайте создадим файл с правилами?")
    let response = readLine()
    if response == "y" {
      if let file = try? Folder.library?.createSubfolder(named: "henghog").createSubfolder(named: "codestyle").createFile(named: "rules.json") {
        run("open \(file.path)")
      }
    }
  }

  private func getRules(_ target: CodeStyleType) -> Rules? {
    var fileRules = try? File(path: "\(Folder.library?.path ?? "")henghog/codestyle/rules.json")
    switch target {
    case .directory(let folder):
      fileRules = seach(folder: folder, name: "\(Rules.nameFile).json")
    case .file(let file):
      fileRules = seach(folder: file.parent!, name: "\(Rules.nameFile).json")
    }

    if fileRules == nil {

    }
    if
      let data = try? fileRules?.read(),
      let model = try? JSONDecoder().decode(Rules.self, from: data)
    {
      return model
    }

    return nil
  }

  private func seach(folder: Folder, name: String) -> File? {
    if let file = folder.files.first { $0.name == name } {
      return file
    }

    if let parent = folder.parent {
      print(folder.parent)
      return seach(folder: parent, name: name)
    }
    return nil
  }



  private func getTarget() -> CodeStyleType? {
    if arguments.count == 1 {
      return .directory(Folder.current)
    }

    guard arguments.count == 2 else { return nil }

    if let folder = try? Folder(path: arguments[1]) {
      return .directory(folder)
    }

    if let file = try? File(path: arguments[1]), file.extension == "swift" {
      return .file(file)
    }
    return nil
  }

  func run(_ cmd: String) -> String? {
    let pipe = Pipe()
    let process = Process()
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", String(format:"%@", cmd)]
    process.standardOutput = pipe
    let fileHandle = pipe.fileHandleForReading
    process.launch()
    return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
  }
}


struct Rules: Codable {
  let openBraceOneLine: Bool

  static let nameFile = "HenghogRules"
}

enum CodeStyleType {
  case directory(Folder)
  case file(File)
}
