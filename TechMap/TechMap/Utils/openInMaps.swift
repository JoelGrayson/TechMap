//
//  openInMaps.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI

// Written by ChatGPT
func openInMaps(lat: Double, lng: Double, name: String, address: String) {
    let stringToShow="\(name): \(address)"
    let query = stringToShow.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lng)&q=\(query)")!

    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}

