//
//  ScanQRRouter.swift
//  QRIS App
//
//  Created by Ariesta APP on 25/01/24.
//

import Foundation
import PaymentModule

protocol ScanQRRouterProtocol {
    func goToPayment(data: PaymentModel) -> PaymentViewController
}

public class ScanQRRouter: ScanQRRouterProtocol {
    public static let shared = ScanQRRouter()
    
    public func goToPayment(data: PaymentModel) -> PaymentViewController {
        let presenter = PaymentPresenter(router: PaymentRouter.shared, interactor: PaymentInteractor.shared, data: data)
        let vc = PaymentViewController(presenter: presenter)
        return vc
    }
}
