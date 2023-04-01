// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

/// @title defined the interface that will be referenced in main Kitty contract
interface BummyInfoInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isBummyInfo() external view returns (bool) ;

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of dad
    /// @return genes that are supposed to be passed down the child
    function mixGenes(uint256 genes1, uint256 genes2) external returns (uint256);
}