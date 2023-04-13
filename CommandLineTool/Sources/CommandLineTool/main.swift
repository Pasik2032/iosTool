//
//  main.swift
//  
//
//  Created by Даниил Пасилецкий on 05.04.2023.
//

import Foundation

let tool = CommandLineTool()

do {
  try tool.run()
} catch {
  print("Whoops! An error occurred: \(error)")
}
