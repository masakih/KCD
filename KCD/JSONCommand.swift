//
//  JSONCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/19.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

class JSONCommand {
    
    class func canExecuteAPI(_ api: API) -> Bool { return false }
    
    let apiResponse: APIResponse
    
    required init(apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
    }
    
    var api: API { return apiResponse.api }
    var parameter: Parameter { return apiResponse.parameter }
    var json: JSON { return apiResponse.json }
    
    var data: JSON { return json["api_data"] }

    func execute() throws {}
}
