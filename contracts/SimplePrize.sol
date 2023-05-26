// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/// @notice If we list all the natural numbers below 10 that are multiples of
/// 3 or 5, we get 3, 5, 6, and 9. The sum of these multiples is 23.
/// Find the sum of all the multiples of 3 or 5 below 1,000.
contract SimplePrize {
    // the salt to prevent attackers from guessing the answer
    bytes32 public constant salt = bytes32(uint256(987463829));
    // the correct answer created by hashing the salt and the raw answer
    bytes32 public commitment;

    /// @notice create the contract with the answer
    constructor(bytes32 _commitment) payable {
        commitment = _commitment;
    }

    /// @notice the answer hash function
    function createCommitment(uint answer) public pure returns (bytes32) {
        return keccak256(abi.encode(salt, answer));
    }

    /// @notice compare user input with the correct answer
    function guess(uint answer) public {
        require(createCommitment(answer) == commitment);
        payable(msg.sender).transfer(address(this).balance);
    }
    
    /// @notice the contract can be funded
    fallback () external payable {}
    receive() external payable {}
}