//
//  PBKDF2.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 05/04/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public extension PKCS5 {
    /// A key derivation function.
    ///
    /// PBKDF2 - Password-Based Key Derivation Function 2. Key stretching technique.
    ///          DK = PBKDF2(PRF, Password, Salt, c, dkLen)
    public struct PBKDF2 {

        public enum Error: Error {
            case invalidInput
            case derivedKeyTooLong
        }

        fileprivate let salt: Array<UInt8>   // S
        fileprivate let iterations: Int // c
        fileprivate let numBlocks: UInt // l
        fileprivate let dkLen: Int;
        fileprivate let prf: HMAC

        /// - parameters:
        ///   - salt: salt
        ///   - variant: hash variant
        ///   - iterations: iteration count, a positive integer
        ///   - keyLength: intended length of derived key
        public init(password: Array<UInt8>, salt: Array<UInt8>, iterations: Int = 4096 /* c */, keyLength: Int? = nil /* dkLen */, variant: HMAC.Variant = .sha256) throws {
            precondition(iterations > 0)
            
            guard let prf = HMAC(key: password, variant: variant), iterations > 0 && !password.isEmpty && !salt.isEmpty else {
                throw Error.invalidInput
            }

            self.dkLen = keyLength ?? variant.size
            let keyLengthFinal = Double(self.dkLen)
            let hLen = Double(prf.variant.size)
            if keyLengthFinal > (pow(2,32) - 1) * hLen {
                throw Error.derivedKeyTooLong
            }

            self.salt = salt
            self.iterations = iterations
            self.prf = prf

            self.numBlocks = UInt(ceil(Double(keyLengthFinal) / hLen))  // l = ceil(keyLength / hLen)
        }

        public func calculate() -> Array<UInt8> {
            var ret = Array<UInt8>()
            for i in 1...self.numBlocks {
                // for each block T_i = U_1 ^ U_2 ^ ... ^ U_iter
                if let value = calculateBlock(salt: self.salt, blockNum: i) {
                    ret.append(contentsOf: value)
                }
            }
            return Array(ret.prefix(self.dkLen))
        }
    }
}

private extension PKCS5.PBKDF2 {
    func INT(_ i: UInt) -> Array<UInt8> {
        var inti = Array<UInt8>(repeating: 0, count: 4)
        inti[0] = UInt8((i >> 24) & 0xFF)
        inti[1] = UInt8((i >> 16) & 0xFF)
        inti[2] = UInt8((i >> 8) & 0xFF)
        inti[3] = UInt8(i & 0xFF)
        return inti
    }

    // F (P, S, c, i) = U_1 \xor U_2 \xor ... \xor U_c
    // U_1 = PRF (P, S || INT (i))
    func calculateBlock(salt: Array<UInt8>, blockNum: UInt) -> Array<UInt8>? {
        guard let u1 = prf.authenticate(salt + INT(blockNum)) else {
            return nil
        }

        var u = u1
        var ret = u
        if self.iterations > 1 {
            // U_2 = PRF (P, U_1) ,
            // U_c = PRF (P, U_{c-1}) .
            for _ in 2...self.iterations {
                u = prf.authenticate(u)!
                for x in 0..<ret.count {
                    ret[x] = ret[x] ^ u[x]
                }
            }
        }
        return ret
    }
}
