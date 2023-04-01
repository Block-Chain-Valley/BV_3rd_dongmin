// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "../Interface/BummyInfoInterface.sol";
import "../Interface/BummyCoreInterface.sol";

/// @title GeneScience implements the trait calculation for new kitties
/// @author Axiom Zen, Dieter Shirley <dete@axiomzen.co> (https://github.com/dete), Fabiano P. Soriani <fabianosoriani@gmail.com> (https://github.com/flockonus), Jordan Schalm <jordan.schalm@gmail.com> (https://github.com/jordanschalm), Abhishek Chadha <abhishek@dapperlabs.com> (https://github.com/achadha235)
contract GeneScience {
    bool public isGeneScience = true;

    // This is the privileged birther address. If this is set to 0, privileged birthing is disabled
    address internal _privilegedBirther;
    // Privileged window size for birthers, set to 5 blocks.
    uint256 public privilegedBirtherWindowSize = 5;
    BummyCoreInterface _bummyCore;

    constructor(address _privilegedBirtherAddress, address _bummyCoreAddress) {
        require(_bummyCoreAddress != address(0));
        _bummyCore = BummyCoreInterface(_bummyCoreAddress); 
        _privilegedBirther = _privilegedBirtherAddress;
    }

    /// @dev the function as defined in the breeding contract - as defined in CK bible
    function mixGenes(uint256 _genes1, uint256 _genes2) public view returns (uint256) {
        return _mixGenes(_genes1,_genes2);
    }
    function _mixGenes(uint256 _genes1, uint256 _genes2) internal view returns(uint256) {
        
		/* 자유롭게 작성하세요.*/
    }
    
}