/*
  DefaultKey.swift

 Copyright (c) 2017, Hori, Masaki.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

/*
 
 DefaultKey.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-01-03.
 
 ------------------------------------------------------------------------------
 
 © 2016-2017 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Foundation

class DefaultKeys: RawRepresentable, Hashable, CustomStringConvertible {
    
    let rawValue: String
    
    
    required init(rawValue: String) {
        
        self.rawValue = rawValue
    }
    
    
    var hashValue: Int {
        
        return self.rawValue.hashValue
    }
    
    
    var description: String {
        
        return self.rawValue
    }
    
}

final class DefaultKey<T>: DefaultKeys {
    
    private let rawAlternativeValue: T?
    
    let regulator: (T) -> T
    
    
    init(_ rawValue: String, alternative value: T? = nil, regulator: @escaping (T) -> T = { $0 }) {
        
        self.rawAlternativeValue = value
        self.regulator = regulator
        
        super.init(rawValue: rawValue)
        
    }
    
    required convenience init(rawValue: String) {
        
        self.init(rawValue)
    }
    
    
    var alternative: T {
        
        switch rawAlternativeValue {
        case .none: fatalError("DefaultKey (\(self)) has no alternative value.")
        case let .some(value): return value
        }
    }
    
}


extension UserDefaults {
    
    subscript(key: DefaultKey<Bool>) -> Bool {
        
        get { return self.bool(forKey: key.rawValue) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<Int>) -> Int {
        
        get { return key.regulator(self.integer(forKey: key.rawValue)) }
        set { self.set(key.regulator(newValue), forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<Double>) -> Double {
        
        get { return key.regulator(self.double(forKey: key.rawValue)) }
        set { self.set(key.regulator(newValue), forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<CGFloat>) -> CGFloat {
        
        get { return key.regulator(CGFloat(self.double(forKey: key.rawValue))) }
        set { self.set(key.regulator(newValue), forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<String?>) -> String? {
        
        get { return self.string(forKey: key.rawValue) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
}
