//
//  Package.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 4/20/16.
//	Copyright (C) 2016 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

//		.Package(url: "https://github.com/crossroadlabs/Markdown.git", versions: Version(0,0,0)..<Version(10,0,0))

import PackageDescription

let package = Package(
	name: "PerfectDocGenerator",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/PerfectLib.git", majorVersion:3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Zip.git", majorVersion:3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Markdown.git", majorVersion: 3)
    ]
)
