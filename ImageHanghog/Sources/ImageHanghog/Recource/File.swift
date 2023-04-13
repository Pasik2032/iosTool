//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 08.04.2023.
//

import Foundation

enum Templete {

  case image(name: String, code: String?)

  var date: String {
    switch self {
    case .image(let name, let code):

      var enu: String

      if let code {
        enu = code
      } else {
        enu =
"""
enum \(name) {

}
"""
      }
      return
"""
//
//  \(name).swift
//
//
//  Created by Hanghoog.
//

import UIKit

\(enu)
"""
    }
    
  }

}



//
//  DirectoryObserver.swift
//  DirectoryObserver
//
//  Created by Ravi Tripathi on 28/06/20.
//  Copyright © 2020 Ravi Tripathi. All rights reserved.
//

import Foundation

public enum DirectoryObserverError: Error  {
  case failedToInitialize(reason: String)
}

public protocol DirectoryObserverDelegate {
  func didChange(currentUrls: [URL])
}

public class DirectoryObserver {

  var url: URL
  var fileURLs = [URL]()
  var observer: FSObserver?
  public var delegate: DirectoryObserverDelegate?

  /// Create a new Directory Observer
  /// - Parameters:
  ///   - url: URL of the directory to be observed
  ///   - fileSystemEvent: The DispatchSource.FileSystemEvent to which the observer should response. By default, it responds to all events
  /// - Throws: Throws an exception if the url passed does not point to a directory or does not exist
  public init(atFolderURL url: URL,
              fileSystemEvent: DispatchSource.FileSystemEvent = .all) throws {
    var isDirectory: ObjCBool = true
    let fileExists = FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &isDirectory)
    if !fileExists {
      throw DirectoryObserverError.failedToInitialize(reason: "No resource found at provided URL")
    }
    if !isDirectory.boolValue {
      throw DirectoryObserverError.failedToInitialize(reason: "URL provided is not a directory")
    }
    self.url = url
    updateCurrentFiles()
    observer = FSObserver(URL: self.url, fileSystemEvent: fileSystemEvent) { [weak self] in
      guard let self = self else { return }
      self.updateCurrentFiles()
    }
  }

  func updateCurrentFiles() {
    var urlS = [URL]()
    let enumerator = FileManager.default.enumerator(atPath: self.url.path)
    guard let filePaths = enumerator?.allObjects as? [String] else {
      return
    }
    for filePath in filePaths {
      let fileURL = self.url.appendingPathComponent("\(filePath)")
      urlS.append(fileURL)
    }
    self.fileURLs = urlS
    self.delegate?.didChange(currentUrls: self.fileURLs)
  }
}


//
//  FSObserver.swift
//  DirectoryObserver
//
//  Created by Ravi Tripathi on 28/06/20.
//  Copyright © 2020 Ravi Tripathi. All rights reserved.
//

import Foundation

public class FSObserver {

  private let fileDescriptor: CInt
  private let source: DispatchSourceProtocol

  deinit {
    self.source.cancel()
    close(fileDescriptor)
  }

  public init(URL: URL,
              fileSystemEvent: DispatchSource.FileSystemEvent,
              block: @escaping ()->Void) {
    self.fileDescriptor = open(URL.path, O_EVTONLY)
    self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor, eventMask: fileSystemEvent, queue: DispatchQueue.global())
    self.source.setEventHandler {
      block()
    }
    self.source.resume()
  }
}
