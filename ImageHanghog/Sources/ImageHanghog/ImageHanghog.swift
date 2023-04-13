
import Foundation
import Files

struct XCAsset: Equatable {
  let FolderAsset: FolderAsset
  let code: File
}

struct FolderAsset: Equatable {
  let name: String
  var valueName: [String]
  var folders: [FolderAsset]
}

enum Command {
  case create(type: TypeAccet)
  case detect(folder: Folder?)
  case update(folder: Folder?)

  init?(arguments: [String]) {
    guard arguments.count > 2 else { return nil }
    switch arguments[1] {
    case "init":
      if let type = TypeAccet(rawValue: arguments[2]) {
        self = .create(type: type)
      } else {
        return nil
      }
    case "detect":
      let folder = try? Folder(path: arguments[2])
      self  = .detect(folder: folder)
    case "update":
      let folder = try? Folder(path: arguments[2])
      self = .update(folder: folder)
    default: return nil
    }
  }
}

enum TypeAccet: String {
  case image
}

public final class ImageHanghog {

  private let arguments: [String]

  private var currentAccet: [XCAsset]?

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  func run() {
    guard let command = Command(arguments: arguments) else {
      print("Извините но произошла ошибка!")
      return
    }
    switch command {
    case .create(let type): createAccet(type: type)
    case .update(let folder): update(folder: folder)
    case .detect(let folder): detect(folder: folder)
    }
  }

  private func detect(folder: Folder?) {
    let folde = folder ?? Folder.current

    currentAccet = allFolder(folder: folde)

    while true {
      if currentAccet != allFolder(folder: folde) {
        update(folder: folder)
        currentAccet = allFolder(folder: folde)
      }
    }
  }

  private func allFolder(folder: Folder) -> [XCAsset] {
    var xcassets = folder.subfolders.filter { $0.extension == "xcassets" }
    if folder.extension == "xcassets" {
      xcassets.append(folder)
    }

    let folder = folder.subfolders.filter { $0.extension == nil }

    var a = xcassets.compactMap { fol in
      let file = fol.parent?.files.first { $0.nameExcludingExtension == fol.nameExcludingExtension && $0.extension == "swift" }
      if let file {
        return XCAsset(
          FolderAsset: allFolderAccet(folder: fol),
          code: file
        )
      } else {
        return nil
      }

    }

    folder.forEach {
      a += allFolder(folder: $0)
    }

    return a
  }

  private func update(folder: Folder?) {

    let folde = folder ?? Folder.current

    let accets = allFolder(folder: folde)

    accets.forEach {
      let code = getCode($0.FolderAsset)
      do {
        try $0.code.write(Templete.image(name: $0.FolderAsset.name, code: code).date, encoding: .utf8)
      } catch {
      }
    }
  }

  private func getCode(_ assets: FolderAsset) -> String {
    let enumCode = "enum \(assets.name) {\n"
    let lines = assets.valueName.map {
      "static let \($0) = UIImage(named: \"\($0)\", in: .module, compatibleWith: nil)!"
    }

    let enums = assets.folders.map {
      "\n\n" + getCode($0)
    }
    let endEnum = "\n}"
    return enumCode + lines.joined(separator: "\n") + enums.joined() + endEnum
  }

  private func allFolderAccet(folder: Folder) -> FolderAsset {

    let sets = folder.subfolders.filter { $0.extension == "imageset" }

    let names = sets.map { $0.nameExcludingExtension }

     let a = folder.subfolders.filter { $0.extension == nil }

    var folders: [FolderAsset] = []
      a.forEach {
        folders.append(allFolderAccet(folder: $0))
      }

    return FolderAsset(
      name: folder.nameExcludingExtension,
      valueName: names,
      folders: folders
    )
  }

  private func createAccet(type: TypeAccet) {
    let folder = Folder.current
    print("Введите имя assets: ")
    let name = readLine()
    guard let name else { return }

    guard let newFolder = try? folder.createSubfolder(named: name) else {
      print("error")
      return
    }
    guard (try? newFolder.createSubfolder(named: "\(name).xcassets")) != nil else {
      print("error")
      return
    }

    guard let file = try? newFolder.createFile(named: "\(name).swift") else {
      print("error")
      return
    }

    guard ( try? file.write(Templete.image(name: name, code: nil).date, encoding: .utf8)) != nil else {
      print("error")
      return
    }

    print("Файл успешно создан!")
  }
}
