// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract AddressValidations {
    /// @param hash the data hash
    /// @param v the recovery identifier v, range from 27 to 30
    /// @param r x coordinate of the ECDSA curve
    /// @param s derived from r
    /// @return address the signer address
    function ExtractAddress(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s);
    }

    /// @param hash the data hash
    /// @param sig the signature
    /// @return address the signer address
    function ExtractAddressWithSig(bytes32 hash, bytes memory sig) public pure returns (address) {
        if (sig.length != 65) {
            return address(0);
        }
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s);
    }
}