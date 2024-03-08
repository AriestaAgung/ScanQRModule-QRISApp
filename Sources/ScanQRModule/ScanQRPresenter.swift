//
//  ScanQRPresenter.swift
//  QRIS App
//
//  Created by Ariesta APP on 25/01/24.
//

import Foundation
import UIKit
import PaymentModule

protocol ScanQRPresenterProtocol {
    func goToPayment(nav: UINavigationController, data: PaymentModel)
}

public class ScanQRPresenter: ScanQRPresenterProtocol {
    private var router: ScanQRRouter?
    public init(router: ScanQRRouter? = nil) {
        self.router = router
    }
    
    public func goToPayment(nav: UINavigationController, data: PaymentModel) {
        if let vc = router?.goToPayment(data: data) {
            nav.pushViewController(vc, animated: true)
        }
    }
}
