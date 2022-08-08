//
//  AES.swift
//  CLDcare
//
//  Created by 김영민 on 2022/07/18.
//

import Foundation
//import CryptoSwift

//라이브러리 : https://github.com/krzyzanowskim/CryptoSwift
//pod 'CryptoSwift', '~> 1.3.8'
@objc public class AES256Util: NSObject {
    func test1() {
        
    }
//    //키값 32바이트: AES256(24bytes: AES192, 16bytes: AES128)
//    private static let SECRET_KEY = "01234567890123450123456789012345"
//    private static let IV = "0123456789012345"
//
//    static func encrypt(string: String) -> String {
//        guard !string.isEmpty else { return "" }
//        return try! getAESObject().encrypt(string.bytes).toBase64()
//    }
//
//    static func decrypt(encoded: String) -> String {
//        let datas = Data(base64Encoded: encoded)
//
//        guard datas != nil else {
//            return ""
//        }
//
//        let bytes = datas!.bytes
//        let decode = try! getAESObject().decrypt(bytes)
//
//        return String(bytes: decode, encoding: .utf8) ?? ""
//    }
//
//    private static func getAESObject() -> AES{
//        let keyDecodes : Array<UInt8> = Array(SECRET_KEY.utf8)
//        let ivDecodes : Array<UInt8> = Array(IV.utf8)
//        let aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs5)
//
//        return aesObject
//    }
}
