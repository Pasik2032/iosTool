//
//  TestViewController.swift
//  MGP_Test
//
//  Copyright © 2023 ISS. All rights reserved.
//

import UIKit

// MARK: - Input

protocol TestViewInput: AnyObject {

}

// MARK: - Output

protocol TestViewOutput: AnyObject {
  func viewDidLoad()
}

final class TestViewController: UIViewController {

  // MARK: - UI



  // MARK: - Properties

  var presenter: TestViewOutput?

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    presenter?.viewDidLoad()
    configUI()
  }

  // MARK: - Actions



  // MARK: - Config

  private func configUI() {

    makeConstraints() 
  }

  private func makeConstraints() {

  }
}

// MARK: - TestViewInput

extension TestViewController: TestViewInput {

}
