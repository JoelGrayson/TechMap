//
//  imageURL.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import Foundation

func imageURL(imageName: String) -> URL? {
    URL(string: Constants.imageBasePath+imageName)
}

