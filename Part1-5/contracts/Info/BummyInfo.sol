// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "../Interface/BummyInfoInterface.sol";
import "../Interface/BummyCoreInterface.sol";

contract BummyInfo is BummyInfoInterface {
    bool public isBummyInfo = true;

    BummyCoreInterface _bummyCore;

    constructor(address _bummyCoreAddress) {
        require(_bummyCoreAddress != address(0));
        _bummyCore = BummyCoreInterface(_bummyCoreAddress);
       
    }

    /// @dev the function as defined in the breeding contract - as defined in CK bible
    function mixGenes(
        uint256 _genes1,
        uint256 _genes2
    ) external view override returns (uint256) {
        return _mixGenes(_genes1, _genes2);
    }

    function _mixGenes(
        uint256 _genes1,
        uint256 _genes2
    ) internal view returns (uint256) {
        uint256 gene = uint256(keccak256(abi.encode(block.timestamp))) ^
            (_getFirstNBits(_genes1, 128, 256) + _getLastNBits(_genes2, 128));

        return gene;
    }

    function _getLastNBits(uint x, uint n) internal pure returns (uint) {
        uint mask = (1 << n) - 1;
        return x & mask;
    }

    function _getFirstNBits(
        uint x,
        uint n,
        uint len
    ) internal pure returns (uint) {
        uint mask = ((1 << n) - 1) << (len - n);
        return x & mask;
    }
}