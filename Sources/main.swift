//
//  main.swift
//
//  artnow
//      a remote listening server and adhoc alexa endpoint for the
//      Kodi Picture Slideshow Screensaver
//
//  Copyright © 2017 xbmute. All rights reserved.
//

import Cocoa
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Files

var art_now  : String = ""
var art_last : String = ""


var listen_routes       = Routes()
var alexa_routes        = Routes()

// listening server for for the Kodi Picture Slideshow Screensaver
listen_routes.add(method: .post, uri: "/artnow") {
    req, resp in
    //print(req.postBodyString!)
    if let name = req.postBodyString {
        art_last = art_now
        art_now = name
    }
    print("[now]", art_now, terminator: " ")
    print("[last]", art_last)
    resp.setBody(string: "recorded " + art_now)
    resp.completed()
}

// for remote alexa endpoint, remote service does path/name cleanup
listen_routes.add(method: .get, uri: "/artraw") {
    req, resp in
    resp.setHeader(.contentType, value: "text/plain; charset=UTF-8")
    resp.appendBody(string: art_now + "|" + art_last)
    resp.completed()
}

listen_routes.add(method: .get, uri: "/art") {
    req, resp in
    resp.setHeader(.contentType, value: "text/plain; charset=UTF-8")
    resp.appendBody(string: art_now)
    resp.completed()
}


// adhoc alexa end point
alexa_routes.add(method: .post, uri: "/alexa/artnow") {
    req, resp in
    print(req.postBodyString!)
    var alexa_start = "{\"version\":\"1.0\",\"response\":{\"directives\":[],\"shouldEndSession\":true,\"outputSpeech\":{\"type\":\"SSML\",\"ssml\":\"<speak>"
    var alexa_end   = "</speak>\"}},\"sessionAttributes\":{}}"
    var alexa_text : String = ""
    var art_name = ((art_now as NSString).deletingPathExtension as NSString).lastPathComponent
    alexa_text = alexa_start + art_name + alexa_end
    resp.setBody(string: alexa_text)
    resp.completed()
}

alexa_routes.add(method: .post, uri: "/alexa/artlast") {
    req, resp in
    print(req.postBodyString!)
    var alexa_start = "{\"version\":\"1.0\",\"response\":{\"directives\":[],\"shouldEndSession\":true,\"outputSpeech\":{\"type\":\"SSML\",\"ssml\":\"<speak>"
    var alexa_end   = "</speak>\"}},\"sessionAttributes\":{}}"
    var alexa_text : String = ""
    var art_name = ((art_last as NSString).deletingPathExtension as NSString).lastPathComponent
    alexa_text = alexa_start + "before was: " + art_name + alexa_end
    resp.setBody(string: alexa_text)
    resp.completed()
}

let cert = Folder.current.path + "sslcert/adhoc-alexa.cer"
let pkey = Folder.current.path + "sslcert/private.pem"

do {
    try HTTPServer.launch(
        .server(name: "listen_art",  port: 8000, routes: listen_routes)
        ,.secureServer(TLSConfiguration(certPath: cert, keyPath: pkey),
                      name: "alexa_adhoc", port: 8443, routes: alexa_routes)
    )
} catch PerfectError.networkError(let err, let msg) {
    print("Network error: \(err) \(msg)")
}


