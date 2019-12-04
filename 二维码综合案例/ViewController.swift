//
//  ViewController.swift
//  二维码综合案例
//
//  Created by 瞿杰 on 2019/12/3.
//  Copyright © 2019 yiniu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func createQRCodeBtnClicked(_ sender: UIButton) {
        let createQRCodeVC = CreateQRCodelVc()
        present(createQRCodeVC, animated: true, completion: nil)
    }
    
    @IBAction func DiscernQRCodeBtnClicked(_ sender: UIButton) {
        let discernQRCodeVC = DiscernQRCodeVc()
        present(discernQRCodeVC, animated: true, completion: nil)
    }
    @IBAction func ScanQRCodeBtnClicked(_ sender: UIButton) {
        let scanQRCodeVC = ScanQRCodeVc()
        present(scanQRCodeVC, animated: true, completion: nil)
    }
}

