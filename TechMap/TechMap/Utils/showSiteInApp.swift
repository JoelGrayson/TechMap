//
//  showSiteInApp.swift
//  TechMap
//
//  Created by Joel Grayson on 6/29/25.
//

import Foundation

// Copied from ReadPal
import SafariServices
import UIKit

func showSiteInApp(urlString: String) {
    if let url = URL(string: urlString) {
        let safariVC = SFSafariViewController(url: url) //view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(safariVC, animated: true)
        }
    }
}

