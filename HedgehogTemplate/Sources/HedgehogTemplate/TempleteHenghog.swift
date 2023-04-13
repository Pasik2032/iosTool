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
    workFolder = try! Folder(path: "/Users/pasik/ISS/New/ios-app/Modules")
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

    run("open \(templete.url.absoluteString)")
  }

  private func seachArguments(folder: Folder) -> [String] {
    var arg: [String] = []
    folder.files.forEach {
      arg += matches(for: "\\$\\$[^$]+\\$\\$", in: $0.name)
      if let str = try? $0.readAsString() {
        arg += matches(for: "\\$\\$[^$]+\\$\\$", in: str)
      }
    }
    folder.subfolders.forEach {
      arg += matches(for: "\\$\\$[^$]+\\$\\$", in: $0.name)
      arg += seachArguments(folder: $0)
    }

    return arg
  }

  func matches(for regex: String, in text: String) -> [String] {

    do {
      let regex = try NSRegularExpression(pattern: regex)
      let results = regex.matches(in: text,
                                  range: NSRange(text.startIndex..., in: text))
      return results.map {
        String(text[Range($0.range, in: text)!])
      }
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
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



    return

    let files = allFiles(new, ext: "swift")





let a = workFolder













    files.forEach {
      let str = (try? $0.readAsString()) ?? ""
      let newCode = replaceKey(str, dic: param)
      try? $0.write(newCode)
    }
//    try? new.moveContents(to: a)


    var newFile = new.files.compactMap {
      try? $0.copy(to: a)
    }
    var newFolder = new.subfolders.compactMap {
      try? $0.copy(to: a)
    }

    var allNewFile = newFile
    newFolder.forEach {
      allNewFile += allFiles($0, ext: "swift")
    }
    try? new.delete()




//    self.project = project
//    var lines = bdprofectString.components(separatedBy: "\n")
//    var resgroup = lines
//
//    var beginGroup = 0
//    var endGroup = 0
//
//    for i in 0..<lines.count {
//      if lines[i].contains("Begin PBXGroup section") {
//        beginGroup = i
//      }
//
//      if lines[i].contains("End PBXGroup section") {
//        endGroup = i
//        break
//      }
//    }
//
//
//    let path = fingPath(a)
//
//    print(path)
//    var flag = false
//
//    var currenParrentuuid = ""
//
//    for i in beginGroup...endGroup {
//      if lines[i].contains("children = (") {
//        flag = true
//      }
//
//      if flag, lines[i].contains(path.last ?? "errororororororrooroorororor") {
//        let lin = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
//        currenParrentuuid = String(lin.split(separator: " ")[0])
//        break
//      }
//    }
//
//    var cuuren = path.count - 2
//
//    while cuuren >= 0 {
//      currenParrentuuid = findUUID(file: lines, parent: currenParrentuuid, parentName: path[cuuren + 1], name: path[cuuren])
//      cuuren -= 1
//    }
//
//
//
//    print(currenParrentuuid)
//
//    var allnaeFolder: [Folder] = newFolder
//
//    newFolder.forEach {
//      allnaeFolder += allSubFolders(folder: $0)
//    }
//
//
//    var dic: [URL: String] = [:]
//    allnaeFolder.forEach { folder in
//      let uuid = getUUID()
//      let line = """
//    \(uuid) /* \(folder.name) */ = {
//      isa = PBXGroup;
//      children = (
//      );
//      path = "\(folder.name)";
//      sourceTree = "<group>";
//    };
//"""
//      dic[folder.url] = uuid
//      resgroup.insert(line, at: endGroup)
//
//      endGroup += 1
//    }
//
//
//    try? bdprofect.write(resgroup.joined(separator: "\n"))
//    lines = try! bdprofect.readAsString().components(separatedBy: "\n")
//    resgroup = lines
//    for i in beginGroup..<lines.count {
//      if lines[i].contains("End PBXGroup section") {
//        endGroup = i
//        break
//      }
//    }
//
//
//
//
//    var dif = 1
//    allnaeFolder.forEach { folder in
//      let uuidPatent = dic[folder.parent!.url]
//      let line =  "\(dic[folder.url]!) /* \(folder.name) */,"
//      let parent = dic[folder.parent!.url] ?? currenParrentuuid
//      var flag = false
//      var index = 0
//      for i in beginGroup...endGroup {
//        if lines[i].contains("\(parent) /* \(folder.parent!.name) */ = {") {
//          flag = true
//        }
//
//        if flag, lines[i].contains("children = (") {
//          index = i
//          break
//        }
//      }
//
//      resgroup.insert(line, at: index + dif)
//      dif += 1
//    }
//
//
//
//
//
//    try? bdprofect.write(resgroup.joined(separator: "\n"))
//
//
//    lines = try! bdprofect.readAsString().components(separatedBy: "\n")
//
//
//    var res = lines
//
//
//    var buildFileStart = 0
//    var buildFileEnd = 0
//
//    var fileReferenceStatr = 0
//    var fileReferenceEnd = 0
//
//    var groupStart = 0
//    var groupEnd = 0
//
//    var sourcesBuildPhaseStart = 0
//    var sourcesBuildPhaseEnd = 0
//
//    for i in 0..<lines.count {
//
//      if lines[i].contains("Begin PBXBuildFile section") {
//        buildFileStart = i
//      }
//
//      if lines[i].contains("End PBXBuildFile section") {
//        buildFileEnd = i
//      }
//
//      if lines[i].contains("Begin PBXFileReference section") {
//        fileReferenceStatr = i
//      }
//
//      if lines[i].contains("End PBXFileReference section") {
//        fileReferenceEnd = i
//      }
//
//      if lines[i].contains("Begin PBXGroup section") {
//        groupStart = i
//      }
//
//      if lines[i].contains("End PBXGroup section") {
//        groupEnd = i
//      }
//
//      if lines[i].contains("Begin PBXSourcesBuildPhase section") {
//        sourcesBuildPhaseStart = i
//      }
//
//
//      if lines[i].contains("End PBXSourcesBuildPhase section") {
//        sourcesBuildPhaseEnd = i
//      }
//    }
//
//
//     dif = 0
//
//    allNewFile.forEach { file in
//      let uuid1 = getUUID()
//      let uuid2 = getUUID()
//
//
//      let buildFile = "\(uuid1) /* \(file.name) in Sources */ = {isa = PBXBuildFile; fileRef = \(uuid2) /* \(file.name) */; };"
//      res.insert(buildFile, at: buildFileEnd + dif)
//      dif += 1
//
//      let fileReference = "\(uuid2) /* textFile.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \(file.name); sourceTree = \"<group>\"; };"
//      res.insert(fileReference, at: fileReferenceEnd + dif)
//      dif += 1
//
//
//
//      let folder = file.parent!
//
//      let group = "\(uuid2) /* \(file.name) */,"
//
//      let path = fingPath(file.parent!)
//
//      print(path)
//      var flag = false
//
//      var uuid = ""
//
//      for i in groupStart...groupEnd {
//        if lines[i].contains("children = (") {
//          flag = true
//        }
//
//        if flag, lines[i].contains(path.last ?? "errororororororrooroorororor") {
//          var lin = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
//          uuid = String(lin.split(separator: " ")[0])
//          break
//        }
//      }
//
//      var cuuren = path.count - 2
//
//      while cuuren >= 0 {
//        uuid = findUUID(file: lines, parent: uuid, parentName: path[cuuren + 1], name: path[cuuren])
//        cuuren -= 1
//      }
//
//
//      print(uuid)
//
//
//      var finalLine = 0
//      var fl = false
//      for i in groupStart...groupEnd {
//        if lines[i].contains("\(uuid) /* \(path[0]) */ = {") {
//          fl = true
//        }
//        if fl, lines[i].contains(");") {
//          finalLine = i
//          break
//        }
//      }
//
//            res.insert(group, at: finalLine + dif)
//      dif += 1
//
//
//
//      let sourcesBuildPhase = "\(uuid1) /* \(file.name) in Sources */,"
//
//      var indexLine = 0
//      var ffflag = false
//      for i in sourcesBuildPhaseStart...sourcesBuildPhaseEnd {
//        if lines[i].contains("files = (") {
//          ffflag = true
//        }
//
//        if ffflag, lines[i].contains(");") {
//          indexLine = i
//          break
//        }
//      }
//      res.insert(sourcesBuildPhase, at: indexLine + dif)
//      dif += 1
//    }
//
//    try? bdprofect.write(res.joined(separator: "\n"))

  }

  private func findUUID(file: [String], parent: String, parentName: String, name: String) -> String {
    var flag = false
    var secongFlag = false
    var startindex = 0
    var endindex = 0
    for i in 0..<file.count {
      if file[i].contains("\(parent) /* \(parentName) */ = {") {
        flag = true
      }

      if flag, file[i].contains("children = (") {
        startindex = i + 1
          secongFlag = true
      }

      if secongFlag, file[i].contains(");") {
        endindex = i - 1
        break
      }
    }

    var index = 0
    for i in startindex...endindex {
      if file[i].contains(name) {
        index = i
        break
      }
    }

    var lin = file[index].trimmingCharacters(in: .whitespacesAndNewlines)

    return String(lin.split(separator: " ")[0])
  }

  private func fingPath(_ folder: Folder) -> [String] {


    if folder == project?.parent {
      return []
    }

    var res: [String]  = [folder.name]

    if let parent = folder.parent {
      res += fingPath(parent)
    }

    return res
  }

  private func getUUID() -> String {
    var gen = run("uuidgen")
    gen?.replace("-", with: "")
    let shortString = String(gen?.prefix(24) ?? "")
    return shortString
  }

  private func seachProject(folder: Folder) -> Folder? {
    let folders = folder.subfolders.first { $0.extension == "xcodeproj" }

    if let folders {
      return folders
    }

    if let parent = folder.parent {
      return seachProject(folder: parent)
    } else {
      return nil
    }
  }

  private func replaceKey(_ file: String, dic: [String: String]) -> String {
    var res = file
    dic.forEach { (key, value) in
      res = res.replacingOccurrences(of: "$$\(key)$$", with: value)
    }
    return res
  }

  private func allFiles(_ folder: Folder, ext: String) -> [File] {
    var files = folder.files.filter { $0.extension == ext }
    folder.subfolders.forEach {
      files += allFiles($0, ext: ext)
    }

    return files
  }

  private func allSubFolders(folder: Folder) -> [Folder] {
    var arr: [Folder] = Array(folder.subfolders)
    folder.subfolders.forEach {
      arr += allSubFolders(folder: $0)
    }
    return arr
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


extension String {
  func chopPrefix(_ count: Int = 1) -> String {
    return substring(from: index(startIndex, offsetBy: count))
  }

  func chopSuffix(_ count: Int = 1) -> String {
    return substring(to: index(endIndex, offsetBy: -count))
  }
}
