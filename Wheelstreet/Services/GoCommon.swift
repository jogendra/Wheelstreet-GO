//
//  GoCommon.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 06/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

class GoCommon {
    
    public static var isFirstTimeUser: Bool = {
        return UserDefaults.standard.value(forKey: GoKeys.accessToken) != nil ? false : true
    }()

    
}

