//
//  utilities.swift
//  PerfectDocGenerator
//
//  Created by Jonathan Guthrie on 2016-07-16.
//
//

import PerfectLib

#if os(Linux)
	import SwiftGlibc
#else
	import Darwin
#endif

func runProc(_ cmd: String, args: [String], read: Bool = false) throws -> String? {
	let envs = [("PATH", "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local:/usr/local/Cellar"),
	            ("LANG", "en_CA.UTF-8")]
	let proc = try SysProcess(cmd, args: args, env: envs)
	var ret: String?
	if read {
		var ary = [UInt8]()
		while true {
			do {
				guard let s = try proc.stdout?.readSomeBytes(count: 1024) , s.count > 0 else {
					break
				}
				ary.append(contentsOf: s)
			} catch PerfectLib.PerfectError.fileError(let code, _) {
				if code != EINTR {
					break
				}
			}
		}
		ret = UTF8Encoding.encode(bytes: ary)
		//print(ret)
	}
	let res = try proc.wait(hang: true)
	if res != 0 {
		let s = try proc.stderr?.readString()
		throw  PerfectError.systemError(Int32(res), s!)
	}
	return ret
}

func runTOC(_ str: String) -> String {
	var out = ""
	do {
		let thisJSON = try str.jsonDecode() as? [String:Any]
		let contents = thisJSON!["contents"] as! [Any]
		out += runTOCnode(contents)
	} catch let e {
		print(e)
		return out
	}
	return out
}

func runTOCnode(_ json: [Any]) -> String {
	var out = ""
	for index in 0..<json.count {
		let thisNode = json[index] as! [String:Any]
		let thisDoc = thisNode["doc"]
		let thisName = thisNode["name"]
		var thisLink = thisDoc as! String
		if thisLink == "introduction" {
			thisLink = " index"
		}
		out += "<li><a href='\(thisLink).html' class='noul'>\(thisName!)</a></li>"


		if let thisNested = thisNode["contents"] as? [Any] , thisNested.count > 0 {
			out += runTOCnode(thisNested)
		}
	}
	out = "<ul class='tocmenu'>\(out)</ul>"
	return out
}
