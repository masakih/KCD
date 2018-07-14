//
//  ForXcodebuild.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/07/14.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

// これがないとなぜか xcodebuild でビルドできない
extension NSComparisonPredicate.Options: SetAlgebra {}
