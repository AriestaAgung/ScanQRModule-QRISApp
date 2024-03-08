//
//  ScanQRViewController.swift
//  QRIS App
//
//  Created by Ariesta APP on 25/01/24.
//

import UIKit
import AVFoundation
import PaymentModule

public class ScanQRViewController: UIViewController {
    private var session: AVCaptureSession!
    private var preview: AVCaptureVideoPreviewLayer!
    private var presenter: ScanQRPresenter?
    public init(presenter: ScanQRPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if session?.isRunning == false {
            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session?.isRunning == true {
            session.stopRunning()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        setupCapture()
    }
    
    private func setupCapture() {
        session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            session = nil
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            session = nil
            return
        }
        
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        DispatchQueue.global().async {
            self.session.startRunning()
        }

    }
    
    private func didReadQR(value: String) {
        print(value)
        let arr = value.components(separatedBy: ".")
        let model = PaymentModel(id: arr[1], bankOrigin: arr[0], merchantName: arr[2], amount: Double(arr[3]))
        
        presenter?.goToPayment(nav: self.navigationController!, data: model)
    }

}

extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            didReadQR(value: stringValue)
        }
        dismiss(animated: true)
    }
}
