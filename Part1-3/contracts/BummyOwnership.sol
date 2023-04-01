// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
 
import "./BummyBase.sol";
import "./Interface/BummyOwnershipInterface.sol";
contract BummyOwnership is BummyBase,BummyOwnershipInterface {

    /// @dev _tokenId에 해당하는 token의 owner가 _claimant 과 동일하면 true 아니면 false를 반환
    /// @param _claimant the address we are validating against.
    /// @param _tokenId bummy id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        
    }

    /// @dev 사용자가 실수로 잘못된 주소(BummyCore)로 보냈을 때, 다시 사용자에게 돌려주기 위해 필요함.
    /// _bummyId에 해당하는 token이 현재 이 컨트랙트에 있는지 확인해야 합니다.
    /// 있다면 이를 _recipient한테 돌려보냅니다.
    /// @param _bummyId - ID of bummy
    /// @param _recipient - Address to send the cat to
    function rescueLostBummy(uint256 _bummyId, address _recipient) external onlyCOO whenNotPaused {
        require(_owns(address(this),_bummyId));
        _transfer(address(this), _recipient, _bummyId);
        
    }
}
