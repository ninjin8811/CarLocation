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
    var updatedDate: TimeInterval = 0
    var spotList = [spotData]()
    var latestLocation: locationData?
}

class spotData: Codable {
    var spotName: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
}

class locationData: Codable {
    var latitude: Double = 0
    var longitude: Double = 0
}

extension spotData: Equatable {
    public static func == (lhs: spotData, rhs: spotData) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
