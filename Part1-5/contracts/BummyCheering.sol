// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import './Interface/BummyInfoInterface.sol';
import './Interface/BummyCheeringInterface.sol';
import "./Interface/BummyCoreInterface.sol";

import './BummyOwnership.sol';
contract BummyCheering is BummyOwnership,BummyCheeringInterface{

    event Exhausted(address owner, uint256 momId, uint256 dadId);
    
    /// @dev 무작위 
    BummyInfoInterface public bummyGene;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function setBummyInfoAddress(address _address) external onlyCEO {
        BummyInfoInterface candidateContract = BummyInfoInterface(_address);

        // NOTE: verify that a contract is what we expect
        require(candidateContract.isBummyInfo());

        // Set the new contract address
        bummyGene = candidateContract;
    }


    /// @dev Check if a dad has authorized breeding with this mom. True if both dad
    ///  and mom have the same owner, or if the dad has given siring permission to
    ///  the mom's owner (via approveSiring()).
    function _isCheeringPermitted(uint256 _dadId, uint256 _momId) internal view returns (bool) {
        address momOwner = _ownerOf(_momId);

        // Siring is okay if they have same owner, or if the mom's owner was given
        // permission to breed with this dad.
        return (cheerAllowedToAddress[_dadId] == momOwner);
    }

    /// @dev Set the cooldownEndTime for the given Bummy, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _bummy A reference to the Bummy in storage which needs its timer started.
    function _triggerCooldown(Bummy storage _bummy) internal {
        // Compute the end of the cooldown time (based on current cooldownIndex)
        _bummy.cooldownEndTime = uint64(block.timestamp + cooldowns[_bummy.cooldownIndex]);

        if (_bummy.cooldownIndex < 5 && _bummy.children < 3) {
            _bummy.cooldownIndex += 1;
            _bummy.children += 1;
        }
    }

    /// @notice Grants approval to another user to dad with one of your Bummies.
    /// @param _addr The address that will be able to dad with your Bummy. Set to
    ///  address(0) to clear all siring approvals for this Bummy.
    /// @param _dadId A Bummy that you own that _addr will now be able to dad with.
    function approveCheering(address _addr, uint256 _dadId)
        public
        whenNotPaused
    {
        require(_owns(msg.sender, _dadId));
        cheerAllowedToAddress[_dadId] = _addr;
    }


    /// @dev Checks to see if a given Bummy is pregnant and (if so) if the gestation
    ///  period has passed.
    function _isReadyToGiveBirth(Bummy memory _mom) private view returns (bool) {
        return (_mom.cheeringWithId != 0) && (_mom.cooldownEndTime <= block.timestamp);
    }

    /// @notice Checks that a given bummy is able to breed (i.e. it is not pregnant or
    ///  in the middle of a siring cooldown).
    /// @param _bummyId reference the id of the bummy, any user can inquire about it
    function isReadyToCheer(uint256 _bummyId)
        external
        view
        returns (bool)
    {
        require(_bummyId > 0);
        Bummy storage bum = bummies[_bummyId];
        return _isReadyToCheer(bum);
    }

    /// @dev Checks that a given bummy is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _isReadyToCheer(Bummy memory _bum) internal view returns (bool) {
        // In addition to checking the cooldownEndTime, we also need to check to see if
        // the bum has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_bum.cheeringWithId == 0) && (_bum.cooldownEndTime <= block.timestamp);
    }

    /// @dev 개족보 방지를 위한 함수
    /// @param _mom A reference to the Bummy struct of the potential mom.
    /// @param _momId The mom's ID.
    /// @param _dad A reference to the Bummy struct of the potential dad.
    /// @param _dadId The dad's ID
    function _isValidMatingPair(
        Bummy storage _mom,
        uint256 _momId,
        Bummy storage _dad,
        uint256 _dadId
    )
        private
        view
        returns(bool)
    {
        // A Bummy can't breed with itself!
        if (_momId == _dadId) {
            return false;
        }

        // Bummies can't breed with their parents.
        if (_mom.MomId == _dadId || _mom.DadId == _dadId) {
            return false;
        }
        if (_dad.MomId == _momId || _dad.DadId == _momId) {
            return false;
        }

        // We can short circuit the sibling check (below) if either bum is
        // gen zero (has a mom ID of zero).
        if (_dad.MomId == 0 || _mom.MomId == 0) {
            return true;
        }

        // Bummies can't breed with full or half siblings.
        if (_dad.MomId == _mom.MomId || _dad.MomId == _mom.DadId) {
            return false;
        }
        if (_dad.DadId == _mom.MomId || _dad.DadId == _mom.DadId) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }


    /// @notice 개족보가 아니고, 쿨타임이 아닐때
    /// @param _momId The ID of the proposed mom.
    /// @param _dadId The ID of the proposed dad.
    function canCheerWith(uint256 _momId, uint256 _dadId)
        public
        view
        returns(bool)
    {
        require(_momId > 0);
        require(_dadId > 0);
        Bummy storage mom = bummies[_momId];
        Bummy storage dad = bummies[_dadId];
        return _isValidMatingPair(mom, _momId, dad, _dadId) &&
            _isCheeringPermitted(_dadId, _momId);
    }

    /// @notice Breed a Bummy you own (as mom) with a dad that you own, or for which you
    ///  have previously been given Siring approval. Will either make your bum pregnant, or will
    ///  fail entirely.
    /// @param _momId The ID of the Bummy acting as mom (will end up pregnant if successful)
    /// @param _dadId The ID of the Bummy acting as dad (will begin its siring cooldown if successful)
    function cheerWith(uint256 _momId, uint256 _dadId) external whenNotPaused {
        // Caller must own the mom.
        require(_owns(msg.sender, _momId));

        // Neither dad nor mom are allowed to be on auction during a normal
        // breeding operation, but we don't need to check that explicitly.
        // For mom: The caller of this function can't be the owner of the mom
        //   because the owner of a Bummy on auction is the auction house, and the
        //   auction house will never call cheerWith().
        // For dad: Similarly, a dad on auction will be owned by the auction house
        //   and the act of transferring ownership will have cleared any oustanding
        //   siring approval.
        // Thus we don't need to spend gas explicitly checking to see if either bum
        // is on auction.

        // Check that mom and dad are both owned by caller, or that the dad
        // has given siring permission to caller (i.e. mom's owner).
        // Will fail for _sireId = 0
        require(_isCheeringPermitted(_dadId, _momId));

        // Grab a reference to the potential mom
        Bummy storage mom = bummies[_momId];

        // Make sure mom isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToCheer(mom));

        // Grab a reference to the potential dad
        Bummy storage dad = bummies[_dadId];

        // Make sure dad isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToCheer(dad));

        // Test that these cats are a valid mating pair.
        require(_isValidMatingPair(
            mom,
            _momId,
            dad,
            _dadId
        ));

        // All checks passed, kitty gets pregnant!
        _cheerWith(_momId, _dadId);
    }

    /// @dev Internal utility function to initiate breeding, assumes that all breeding
    ///  requirements have been checked.
    function _cheerWith(uint256 _momId, uint256 _dadId) internal {
        // Grab a reference to the Bummies from storage.
        Bummy storage dad = bummies[_dadId];
        Bummy storage mom = bummies[_momId];

        // Mark the mom as pregnant, keeping track of who the dad is.
        mom.cheeringWithId = uint32(_dadId);

        // Trigger the cooldown for both parents.
        _triggerCooldown(dad);
        _triggerCooldown(mom);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete cheerAllowedToAddress[_momId];
        delete cheerAllowedToAddress[_dadId];

        // Emit the pregnancy event.
        emit Exhausted(_ownerOf(_momId), _momId, _dadId);
    }



    /// @notice Have a pregnant Bummy give birth!
    /// @param _momId A Bummy ready to give birth.
    /// @return The Bummy ID of the new bummy.
    /// @dev Looks at a given Bummy and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new bummy. The new Bummy is assigned
    ///  to the current owner of the mom. Upon successful completion, both the mom and the
    ///  new bummy will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new bummy always goes to the mother's owner.
    function inviteFriend(uint256 _momId)
        external
        whenNotPaused
        returns(uint256)
    {
        // Grab a reference to the mom in storage.
        Bummy storage mom = bummies[_momId];

        // Check that the mom is a valid bum.
        require(mom.birthTime != 0);

        // Check that the mom is pregnant, and that its time has come!
        require(_isReadyToGiveBirth(mom));

        // Grab a reference to the dad in storage.
        uint256 dadId = mom.cheeringWithId;
        Bummy storage dad = bummies[dadId];

        // Determine the higher generation number of the two parents
        uint16 parentGen = mom.generation;
        if (dad.generation > mom.generation) {
            parentGen = dad.generation;
        }

        // Call the sooper-sekret, sooper-expensive, gene mixing operation.
        uint256 childGenes = bummyGene.mixGenes(mom.genes, dad.genes);

        // Make the new bummy!
        address owner = _ownerOf(_momId);
        uint256 bummyId = _createBummy(_momId, mom.cheeringWithId, parentGen + 1, childGenes, owner);

        // Clear the reference to dad from the mom (REQUIRED! Having cheeringWith
        // set is what marks a mom as being pregnant.)
        delete mom.cheeringWithId;

        // return the new bummy's ID
        return bummyId;
    }
}