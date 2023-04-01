// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface BummyOwnershipInterface {
     //* BummyOwnership
    /**
     * @dev 실수로 버미를 Core contract로 보냈을때 복구 시키는 함수입니다.
     * @param _bummyId 실수로 보내진 버미의 토큰 아이디
     * @param _recipient 받을 사람
     */
    function rescueLostBummy(uint256 _bummyId, address _recipient) external;


}