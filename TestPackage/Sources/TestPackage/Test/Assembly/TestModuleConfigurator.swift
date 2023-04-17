//
//  TestModuleConfigurator.swift
//  
//
//  Copyright © 2022. All rights reserved.
//

import UIKit

final class TestModuleConfigurator {

  // MARK: - Configure

  func configure(
    output: TestModuleOutput? = nil,
  ) -> (
    view: TestViewController,
    input: TestModuleInput
  ) {
    let view = TestViewController()
    let presenter = TestPresenter()
    let router = TestRouter()

    presenter.view = view
    presenter.router = router
    presenter.output = output
    presenter.type = type
    presenter.isRestore = isRestore

    router.view = view

    view.output = presenter

    return (view, presenter)
  }
}

