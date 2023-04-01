// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "./BummyMinting.sol";
import "./Interface/BummyCoreInterface.sol";

contract BummyCore is BummyMinting, BummyCoreInterface{
    // Set in case the core contract is broken and an upgrade is required
    BummyCoreInterface public newContractAddress;

    /// @notice Creates Bummy Contracts
    constructor() {
        _pause();
        ceoAddress = msg.sender;
        cooAddress = msg.sender;

        _createBummy(
            0,
            0,
            0,
            type(uint256).max,
            address(0x000000000000000000000000000000000000dEaD)
        );
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        newContractAddress = BummyCoreInterface(_v2Address);
        emit ContractUpgrade(_v2Address);
    }

    /// @notice Returns all the relevant information about a specific bummy.
    /// @param _id The ID of the bummy of interest.
    function getBummy(
        uint256 _id
    )
        external
        view
        returns (
            bool isExhausted,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 cheeringWithId,
            uint256 birthTime,
            uint256 momId,
            uint256 dadId,
            uint256 generation,
            uint256 genes
        )
    {
        Bummy storage bum = bummies[_id];

        // if this variable is 0 then it's not Exhausted
        isExhausted = (bum.cheeringWithId != 0);
        isReady = (bum.cooldownEndTime <= block.timestamp);
        cooldownIndex = uint256(bum.cooldownIndex);
        nextActionAt = uint256(bum.cooldownEndTime);
        cheeringWithId = uint256(bum.cheeringWithId);
        birthTime = uint256(bum.birthTime);
        momId = uint256(bum.MomId);
        dadId = uint256(bum.DadId);
        generation = uint256(bum.generation);
        genes = bum.genes;
    }
}

   
  

    
    

  

    
