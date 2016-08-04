//
//  main.swift
//  PerfectDocGenerator
//
//  Created by Jonathan Guthrie on 2016-07-16.
//	Copyright (C) 2015 PerfectlySoft, Inc.
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

import PerfectLib
import PerfectZip

let workingDir = Dir.workingDir
print("Working Directory: \(workingDir.path)")

let docsDir = Dir("\(workingDir.path)PerfectDocsSource")
//print("docsDir Directory: \(docsDir.path)")

let docsUIDir = Dir("\(workingDir.path)PerfectDocumentation")
//print("docsUIDir Directory: \(docsUIDir.path)")



if docsDir.exists {
	print("Updating Docs Repo")
	try docsDir.setAsWorkingDir()
	let _ = try runProc("git", args: ["pull"], read: true)
} else {
	print("Checking out Docs Repo")
	let _ = try runProc("git", args: ["clone","--depth","1","https://github.com/PerfectlySoft/PerfectDocs.git","PerfectDocsSource"], read: true)
	try docsDir.setAsWorkingDir()
}

let thisDir = Dir("\(workingDir.path)PerfectDocsSource/guide")

var mdFiles = [String]()
try thisDir.forEachEntry(closure: {
	fn in
	// does filename end with md
	if fn.hasSuffix(".md") {
		mdFiles.append(fn)
	}
})


if docsUIDir.exists {
	print("Updating DocsUI Repo")
	try docsUIDir.setAsWorkingDir()
	let _ = try runProc("git", args: ["pull"], read: true)
} else {
	print("Checking out DocsUI Repo")
	try workingDir.setAsWorkingDir()
	let _ = try runProc("git", args: ["clone","--depth","1","https://github.com/PerfectlySoft/PerfectDocsUI.git","PerfectDocumentation"], read: true)
	try docsUIDir.setAsWorkingDir()
}

// rip through JSON TOC
let jsonSource = File("../PerfectDocsSource/guide/toc.json")
let jsonSourceData = try jsonSource.readString()
let toc = runTOC(jsonSourceData)
jsonSource.close()

let sourceFile = File("source.html")
let sourceData = try sourceFile.readString()
let sourceWithTOC = sourceData.stringByReplacing(string: "LOADINGTOC", withString: toc)
sourceFile.close()

print("Generating HTML files now.")
let filePath = Dir.workingDir

print(filePath.path)

for doc in mdFiles {
	var htmlName = doc.stringByReplacing(string: ".md", withString: ".html")

	// force intro to be home
	if htmlName == "introduction.html" {
		htmlName = "index.html"
	}
	let arg = "../PerfectDocsSource/guide/\(doc)"

	let html = try runProc("/usr/local/bin/hoedown", args: ["--fenced-code",arg], read: true)
	var sourceWithHTML = sourceWithTOC.stringByReplacing(string: "LOADINGMD", withString: html!)
	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "<pre><code>", withString: "<pre class=\"brush: swift;\">")
	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "<pre><code class=\"language-swift\">", withString: "<pre class=\"brush: swift;\">")
	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "</code></pre>", withString: "</pre>")


	let fileIs = File("\(filePath.path)\(htmlName)")
	try fileIs.open(.readWrite)
	try fileIs.write(string: sourceWithHTML)
	fileIs.close()

}

print("now compressing artifact")
// reset working dir
do {
	try workingDir.setAsWorkingDir()
} catch {
	print("Cannot reset the working directory")
}
let sourceDir = "PerfectDocumentation"
let destinationZip = "PerfectDocs.zip"
let zippy = Zip()
let ZipResult = zippy.zipFiles(paths: [sourceDir], zipFilePath: destinationZip, overwrite: true, password: "")
//XCTAssert(ZipResult == .ZipSuccess, ZipResult.description)




