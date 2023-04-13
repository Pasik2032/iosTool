//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 08.04.2023.
//

import Foundation

let tool = ImageHanghog()

do {
  try tool.run()
} catch {
  print("Whoops! An error occurred: \(error)")
}
