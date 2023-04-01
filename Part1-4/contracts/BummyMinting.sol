// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

// Auction wrapper functions
import './BummyCheering.sol';
import "./Interface/BummyMintingInterface.sol";
/// @title all functions related to creating kittens
contract BummyMinting is BummyCheering, BummyMintingInterface {
    mapping(address => bool) alreadyMinted;
    // Limits the number of cats the contract owner can ever create.
    uint256 public promoCreationLimit = 100;
    uint256 public gen0CreationLimit = 500;

    // Counts the number of bummies the contract owner has created.
    uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;

    /// @dev we can create promo bummies, up to a limit. Only callable by COO
    /// @param _genes the encoded genes of the bummies to be created, any value is accepted
    /// @param _owner the future owner of the created bummies. Default to contract COO
    function createPromoBummy(uint256 _genes, address _owner) external override onlyCOO returns (uint256){
        if (_owner == address(0)) {
            _owner = cooAddress;
        }
        require(promoCreatedCount < promoCreationLimit);
        require(gen0CreatedCount < gen0CreationLimit);

        promoCreatedCount++;
        gen0CreatedCount++;
        uint256 newbummyId = _createBummy(0, 0, 0, _genes, _owner);
        return newbummyId;
    }

    /**
     * @dev user can create gen0bummy, but only one
     */
    function createFirstGen0Bummy() external returns (uint256){
        require(alreadyMinted[msg.sender] == false, "You already mint bummy");
        uint256 genes = block.timestamp ^ gen0CreatedCount; //* choose diffirent rand function
        gen0CreatedCount++;
        alreadyMinted[msg.sender] = true;
        uint256 newbummyId = _createBummy(0, 0, 0, genes, msg.sender);
        return newbummyId;
    }


}
