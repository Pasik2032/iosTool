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
