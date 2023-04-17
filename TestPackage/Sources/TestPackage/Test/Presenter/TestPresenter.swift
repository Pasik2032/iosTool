//
//  TestPresenter.swift
//  MGP_Test
//
//  Copyright © 2023 ISS. All rights reserved.
//

import UIKit

// MARK: - Input

protocol TestModuleInput: AnyObject {

}

// MARK: - Output

protocol TestModuleOutput: AnyObject {

}

final class TestPresenter {

    // MARK: - Properties

  weak var view: TestViewInput?
  var router: TestRouterInput?
  weak var output: TestModuleOutput?
}

extension TestPresenter: TestViewOutput {

  func viewDidLoad() {

  }
}

extension TestPresenter: TestModuleInput {

}