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

let workingDir = Dir.workingDir
print("Working Directory: \(workingDir.path)")

let docsDir = Dir("\(workingDir.path)PerfectDocs")
//print("docsDir Directory: \(docsDir.path)")

let docsUIDir = Dir("\(workingDir.path)PerfectDocsUI")
//print("docsUIDir Directory: \(docsUIDir.path)")



if docsDir.exists {
	print("Updating Docs Repo")
	try docsDir.setAsWorkingDir()
	let _ = try runProc(cmd: "git", args: ["pull"], read: true)
} else {
	print("Checking out Docs Repo")
	let _ = try runProc(cmd: "git", args: ["clone","https://github.com/PerfectlySoft/PerfectDocs.git"], read: true)
	try docsDir.setAsWorkingDir()
}

//let thisDir = Dir("/path/to/directory/")
//try thisDir.setAsWorkingDir()

let thisDir = Dir("\(workingDir.path)PerfectDocs/guide")

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
	let _ = try runProc(cmd: "git", args: ["pull"], read: true)
} else {
	print("Checking out DocsUI Repo")
	try workingDir.setAsWorkingDir()
	let _ = try runProc(cmd: "git", args: ["clone","https://github.com/PerfectlySoft/PerfectDocsUI.git"], read: true)
	try docsUIDir.setAsWorkingDir()
}

// rip through JSON TOC
let jsonSource = File("../PerfectDocs/guide/toc.json")
let jsonSourceData = try jsonSource.readString()
let toc = runTOC(str: jsonSourceData)
jsonSource.close()

let sourceFile = File("source.html")
let sourceData = try sourceFile.readString()
let sourceWithTOC = sourceData.stringByReplacing(string: "LOADINGTOC", withString: toc)
sourceFile.close()

print("Generating HTML files now.")
let filePath = Dir.workingDir

print(filePath.path)

for doc in mdFiles {
	let htmlName = doc.stringByReplacing(string: ".md", withString: ".html")
	let arg = "../PerfectDocs/guide/\(doc)"
//	let html = try runProc(cmd: "/usr/local/bin/kramdown", args: ["--input","GFM","--syntax-highlighter","rouge","--syntax-highlighter-opts","{default_lang : bash}",arg], read: true)
	//	let html = try runProc(cmd: "/usr/local/bin/redcarpet", args: ["fenced_code_blocks",arg], read: true)
	let html = try runProc(cmd: "/usr/local/bin/hoedown", args: ["--fenced-code",arg], read: true)
	var sourceWithHTML = sourceWithTOC.stringByReplacing(string: "LOADINGMD", withString: html!)
	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "<pre><code>", withString: "<pre class=\"brush: swift;\">")
	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "<pre><code class=\"language-swift\">", withString: "<pre class=\"brush: swift;\">")
	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "</code></pre>", withString: "</pre>")




//	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "<p><code>", withString: "<pre><code>")
//	sourceWithHTML = sourceWithHTML.stringByReplacing(string: "</code></p>", withString: "</code></pre>")


	let fileIs = File("\(filePath.path)\(htmlName)")
	try fileIs.open(.readWrite)
	try fileIs.write(string: sourceWithHTML)
	fileIs.close()
}




