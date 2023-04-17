import Foundation
import Files


final class HedgehogTemplate {

  private let arguments: [String]

  private let templeteFolder: Folder
  private let tmpFolder: Folder
  private let workFolder: Folder
  private let typeProject: TypeProject

  private var project: Folder?
  private var groupPath: [String]?
  private var param : [String: String] = [:]

  public init?(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
    guard
      let library = Folder.library,
      let templete = try? library.createSubfolderIfNeeded(at: "henghog/templete"),
      let tmp = try? library.createSubfolderIfNeeded(at: "henghog/tmp")
    else {
      print("Unfortunately, the program could not access the necessary folders.")
      print("Grant access and try again")
      return nil
    }

    if let arg = arguments[safe: 1] {
      groupPath = arg.split(separator: "/").map { String($0) }
    }
    workFolder = Folder.current
    templeteFolder = templete
    tmpFolder = tmp

    guard let typeProject = TypeProject(folder: workFolder) else {
      print("Не удалось найти проект, программа должна быть запущена из проекта или package")
      return nil
    }

    self.typeProject = typeProject
  }


  private func createTemplete() {
    print("Вы хотите создать шаблон?")
    print("для подтверждение ввыедите \"y\" если согласны, или что-то другое если не согласны")
    guard "y" == readLine() else { return }
    print("Введите название шаблона: ")
    var name = readLine()
    while name?.isEmpty ?? true {
      print("Имя не корректно")
      print("Введите название шаблона: ")
      name = readLine()
    }
    guard let templete = try? templeteFolder.createSubfolder(named: "\(name!).templete") else {
      print("Такое имя уже существует")
      return
    }

    print("В открывшейся папки вам необходимо создать шаблоны, все что вы создадите будет генерироваться автоматически при использовании шаблона. Вы можете создавать swift файлы или папки. Также внутри названия файлов/папок или в их сожержании вы можете использовать аргументы они указываются между 4 знаками доллара, например: $$argyment1$$. При генерации шаблона вам будет предлженно ввыести значение этих аргументов.")

    HedgehogTemplate.run("open \(templete.url.absoluteString)")
  }

  private func seachArguments(folder: Folder) -> [String] {
    var arg: [String] = []
    folder.files.forEach {
      arg += $0.name.matches(for: "\\$\\$[^$]+\\$\\$")
      if let str = try? $0.readAsString() {
        arg += str.matches(for: "\\$\\$[^$]+\\$\\$")
      }
    }
    folder.subfolders.forEach {
      arg += $0.name.matches(for: "\\$\\$[^$]+\\$\\$")
      arg += seachArguments(folder: $0)
    }

    return arg
  }

  private func replaceArguments(in folder: Folder, with arguments: [String: String?]) {
    folder.files.forEach { file in
      arguments.forEach { (key: String, value: String?) in
        try? file.rename(to: file.name.replacingOccurrences(of: key, with: value ?? ""))
        if let str = try? file.readAsString() {
          try? file.write(str.replacingOccurrences(of: key, with: value ?? ""))
        }
      }
    }
    folder.subfolders.forEach { folder in
      arguments.forEach { (key: String, value: String?) in
        try? folder.rename(to: folder.name.replacingOccurrences(of: key, with: value ?? ""))
        replaceArguments(in: folder, with: arguments)
      }
    }
  }


  func run() {
    let tempetes = templeteFolder.subfolders.filter { $0.extension == "templete" }
    if tempetes.isEmpty {
      print("У вас не ни одного шаблона")
      createTemplete()
      return
    }

    print("Выберите шаблон, написав его номер")
    for (index, element) in tempetes.enumerated() {
      print("\(index). \(element.nameExcludingExtension)")
    }

    guard let select = Int(readLine() ?? ""),  let templete = tempetes[safe: select] else {
      print("Введен некорректный номер")
      return
    }

    guard let new = try? templete.copy(to: tmpFolder) else {
      print("Произошла ошибка!")
      return
    }

    let arg = Set(seachArguments(folder: new))
    var dic: [String: String?] = [:]
    arg.forEach {
      let nameArg = $0.chopPrefix(2).chopSuffix(2)

      print("Введите значение аргумента \(nameArg): ")
      dic[$0] =  readLine()
    }

    replaceArguments(in: new, with: dic)

    let newFile = new.files.compactMap {
      try? $0.copy(to: workFolder)
    }
    let newFolder = new.subfolders.compactMap {
      try? $0.copy(to: workFolder)
    }

    try? new.delete()

    switch typeProject {
    case .project(let bpFile):
      var bp = BPFile(file: bpFile)
      let project = bpFile.parent!.parent!
      let diff = workFolder.path.deletingPrefix(project.path)
      guard let group = bp?.findGroup(for: diff.split(separator: "/").map { String($0) }) else { return  }
      bp?.addTempete(files: newFile, folder: newFolder, group: group)
      let a = bp?.configText()
      if let a {
        try? bpFile.write(a)
      }
      print("файлы успешно сгененрированые")
    case .package:
      print("файлы успешно сгененрированые")
      return
    }
  }

  @discardableResult static func run(_ cmd: String) -> String? {
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
