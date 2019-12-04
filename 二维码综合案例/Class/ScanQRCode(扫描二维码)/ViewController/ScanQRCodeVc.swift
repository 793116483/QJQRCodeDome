//
//  ScanQRCodeVc.swift
//  二维码综合案例
//
//  Created by 瞿杰 on 2019/12/3.
//  Copyright © 2019 yiniu. All rights reserved.
//

import UIKit

class ScanQRCodeVc: UIViewController {
    
    let scanView = ScanView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(scanView)
        scanView.frame = view.bounds
        
    }
    override func viewDidAppear(_ animated: Bool) {
        scanView.beginScanAnimation()
    }
    
    
}


