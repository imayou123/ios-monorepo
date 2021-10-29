//
//  ViewController.swift
//  GiniBankAPILibraryExample
//
//  Created by Nadya Karaban on 28.10.21.
//

import UIKit
import GiniBankAPILibrary
import GiniBankAPILibraryPinning
import TrustKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pinningConfig = [
            kTSKPinnedDomains: [
            "api.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
            "user.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
        ]] as [String: Any]
        
        let lib = GiniBankAPI.Builder(client: Client(id: "", secret: "", domain: "") , api: .default, pinningConfig: pinningConfig, logLevel: LogLevel.debug)    }


}

