//
//  AES.swift
//  CLDcare
//
//  Created by 김영민 on 2022/07/18.
//

import Foundation
import CryptoSwift

//라이브러리 : https://github.com/krzyzanowskim/CryptoSwift
//pod 'CryptoSwift', '~> 1.3.8'
@objc public class AES256Util: NSObject {
    //키값 32바이트: AES256(24bytes: AES192, 16bytes: AES128)
    private static let SECRET_KEY = "0123456789abcdef0123456789abcdef"
    private static let IV = "0123456789abcdef"
    private static func getAESObject() -> AES{
        let keyDecodes : Array<UInt8> = Array(SECRET_KEY.utf8)
        let ivDecodes : Array<UInt8> = Array(IV.utf8)
        let aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs7)
        return aesObject
    }
    
    @objc static func encrypt(string: String) -> String {
        guard !string.isEmpty else { return "" }
        return try! getAESObject().encrypt(string.bytes).toBase64()
    }

    @objc static func decrypt(encoded: String) -> String {
        let datas = Data(base64Encoded: encoded)

        guard datas != nil else {
            return ""
        }

        let bytes = datas!.bytes
        let decode = try! getAESObject().decrypt(bytes)

        return String(bytes: decode, encoding: .utf8) ?? ""
    }
//
//    @objc static func encrypt2(bytes: Array<UInt8>) -> Array<UInt8> {
////        guard !string.isEmpty else { return "" }
//        return try! getAESObject().encrypt(bytes)
//    }
//
//    @objc static func decrypt2(encoded: Array<UInt8>) -> Array<UInt8> {
//        let decode = try! getAESObject().decrypt(encoded)
//        return decode
//    }

    
    @objc static func encrypt(data: Data) -> Data {
//        guard !string.isEmpty else { return "" }
        let encryptedBytes = try! getAESObject().encrypt(data.bytes)
        let encryptedData = Data(encryptedBytes)
        return encryptedData
    }

    @objc static func decrypt(data: Data) -> Data {
        let decryptedBytes = try! getAESObject().decrypt(data.bytes)
        let decryptedData = Data(decryptedBytes)
        return decryptedData
    }

    

    
//    @objc static func decrypt3(data: Data) -> Array<UInt8> {
//        let datas = Data(base64Encoded: "t")
//
//        let bytes = datas!.bytes
//        let decode = try! getAESObject().decrypt(bytes)
//
////        let datas = Data(base64Encoded: "test")
////
////        let decode = try! getAESObject().decrypt(datas!.bytes)
////
////
////        var arr2 = Array<UInt8>(repeating: 0, count: data.count/MemoryLayout<UInt8>.stride)
////        _ = arr2.withUnsafeMutableBytes { data.copyBytes(to: $0) }
////        print(arr2) // [32, 4, 4294967295]
////
//////        let arr: [UInt8] = [8, 12, UInt8.max]
////        let data = Data(buffer: UnsafeBufferPointer(start: arr2, count: arr2.count))
////        print(data) // <20000000 04000000 ffffffff>
//
//
//
//
////        let decode = try! getAESObject().decrypt(arr2)
//        return decode
//    }

    
}
