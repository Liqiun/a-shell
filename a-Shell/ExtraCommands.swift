//
//  extraCommands.swift
//  a-Shell: file for extra commands added to a-Shell.
//  Part of the difficulty is identifying which window scene is active. See history() for an example. 
//
//  Created by Nicolas Holzschuch on 30/08/2019.
//  Copyright © 2019 AsheKube. All rights reserved.
//

import Foundation
import UIKit
import ios_system


@_cdecl("history")
public func history(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
    var rootVC:UIViewController? = nil
    let opaquePointer = OpaquePointer(ios_getContext())
    guard let stringPointer = UnsafeMutablePointer<CChar>(opaquePointer) else { return 0 }
    let currentSessionIdentifier = String(cString: stringPointer)
    for scene in UIApplication.shared.connectedScenes {
        NSLog("identifier: \(scene.session.persistentIdentifier) context = \(currentSessionIdentifier)")
        if (scene.session.persistentIdentifier == currentSessionIdentifier) {
            let delegate: SceneDelegate = scene.delegate as! SceneDelegate
            delegate.printHistory()
            return 0
        }
    }
    return 0
}

@_cdecl("clear")
public func clear(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
    var rootVC:UIViewController? = nil
    let opaquePointer = OpaquePointer(ios_getContext())
    guard let stringPointer = UnsafeMutablePointer<CChar>(opaquePointer) else { return 0 }
    let currentSessionIdentifier = String(cString: stringPointer)
    for scene in UIApplication.shared.connectedScenes {
        NSLog("identifier: \(scene.session.persistentIdentifier) context = \(currentSessionIdentifier)")
        if (scene.session.persistentIdentifier == currentSessionIdentifier) {
            let delegate: SceneDelegate = scene.delegate as! SceneDelegate
            delegate.printHistory()
            return 0
        }
    }
    return 0
}



@_cdecl("tex")
public func tex(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
    let command = argv![0]
    if (downloadingTeXError != "") {
        fputs("There was an error in downloading the TeX distribution: " + downloadingTeXError + "\n", thread_stderr)
    }
    if (downloadingTeX) {
        let percentString = String(format: "%.02f", percentTeXDownloadComplete)
        fputs("Currently updating the TeX distribution. (" + percentString + " % complete)\n", thread_stderr)
        fputs( command, thread_stderr)
        fputs(" will be activated as soon as the download is finished.\n", thread_stderr)
        return 0
    }
    fputs(command, thread_stderr)
    fputs(" requires the TeX distribution, which is not currently installed.\nDo you want to download and install it? (1.8 GB) (y/N)", thread_stderr)
    fflush(thread_stderr)
    var byte: Int8 = 0
    let count = read(fileno(thread_stdin), &byte, 1)
    if (byte == 121) || (byte == 89) {
        fputs("Downloading the TeX distribution, this may take some time...\n", thread_stderr)
        fputs("(you can  remove it later using Settings)\n", thread_stderr)
        UserDefaults.standard.set(true, forKey: "TeXEnabled")
        return 0
    }
    return 0
}

@_cdecl("luatex")
public func luatex(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
    let command = argv![0]
    if (downloadingOpentypeError != "") {
        fputs("There was an error in downloading the LuaTeX extension: ", thread_stderr)
        fputs(downloadingOpentypeError + "\n", thread_stderr)
    }
    if (downloadingTeX) {
        let percentString = String(format: "%.02f", percentTeXDownloadComplete)
        fputs("Currently updating the TeX distribution. (" + percentString + " % complete)\n", thread_stderr)
    }
    if (downloadingOpentype) {
        let percentString = String(format: "%.02f", 100.0 * percentOpentypeDownloadComplete)
        fputs("Currently updating the LuaTeX extension. (" + percentString + " % complete)\n", thread_stderr)
        fputs( command, thread_stderr)
        fputs(" will be activated as soon as the download is finished.\n", thread_stderr)
        return 0
    }
    fputs(command, thread_stderr)
    if (UserDefaults.standard.bool(forKey: "TeXEnabled")) {
        fputs(" requires the LuaTeX extension on top of the TeX distribution\nDo you want to download and install them? (0.5 GB) (y/N)", thread_stderr)
    } else {
        fputs(" requires the TeX distribution, which is not currently installed, along with the LuaTeX extension.\nDo you want to download and install them? (2.3 GB) (y/N)", thread_stderr)
    }
    fflush(thread_stderr)
    var byte: Int8 = 0
    let count = read(fileno(thread_stdin), &byte, 1)
    if (byte == 121) || (byte == 89) {
        if (UserDefaults.standard.bool(forKey: "TeXEnabled")) {
            fputs("Downloading the LuaTeX extension, this may take some time...", thread_stderr)
        } else {
            fputs("Downloading the TeX distribution with LuaTeX extnesion, this may take some time...", thread_stderr)
            UserDefaults.standard.set(true, forKey: "TeXEnabled")
        }
        UserDefaults.standard.set(true, forKey: "TeXOpenType")
        fputs("\n(you can  remove them later using Settings)\n", thread_stderr)
        return 0
    }
    return 0
}