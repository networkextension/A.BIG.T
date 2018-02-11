//
//  Socks.swift
//  Surf
//
//  Created by abigt on 15/12/3.
//  Copyright © 2015年 abigt. All rights reserved.
//

import Foundation
@objc(KKSocks) class Socks :NSObject,NSCoding{
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.proxyName, forKey: "proxyName")
        aCoder.encode(self.serverAddress, forKey: "serverAddress")
        aCoder.encode(self.serverPort, forKey: "serverPort")
        aCoder.encode(self.password, forKey: "password")
        aCoder.encode(self.method, forKey: "method")
        aCoder.encode(self.serverType, forKey: "serverType")
    }

    internal var proxyName:String?
    internal var serverAddress:String?
    internal var serverPort:String?
     var password:String?
     var method:String?
     var serverType:String?
     override init() {}
     required init?(coder aDecoder: NSCoder){
        super.init()

        self.proxyName  = aDecoder.decodeObject(forKey: "proxyName") as? String
        self.serverAddress  = aDecoder.decodeObject(forKey: "serverAddress") as? String
        self.serverPort  = aDecoder.decodeObject(forKey: "serverPort") as? String
        self.password  = aDecoder.decodeObject(forKey: "password") as? String
        self.method  = aDecoder.decodeObject(forKey: "method") as? String
        self.serverType  = aDecoder.decodeObject(forKey: "serverType") as? String
    }
   
    
}
