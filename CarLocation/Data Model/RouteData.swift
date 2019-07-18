//
//  RouteData.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/13.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import Foundation
import CodableFirebase

class RouteData: Codable {
    var routeName: String = "Default"
    var spotList = [spotData]()
}

class spotData: Codable {
    var spotName: String
    var latitude: Double
    var longitude: Double
}
