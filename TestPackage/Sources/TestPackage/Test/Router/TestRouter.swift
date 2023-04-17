//
//  TestViewController.swift
//  MGP_Test
//
//  Copyright © 2023 ISS. All rights reserved.
//

import UIKit

// MARK: - Input

protocol TestRouterInput: AnyObject {

}

final class TestRouter {

  weak var view: UIViewController
}

extension TestRouter: TestRouterInput {

}