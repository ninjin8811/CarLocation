//
//  RouteData.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/13.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import Foundation
import UIKit

class RouteData {
    var routeName = "Default"
    var timeTableImage = UIImage(named: "no-image")
    var spotList = [spotData]()
}

class spotData {
    var spotName = "Default"
    var latitude = 0
    var longitude = 0
}
