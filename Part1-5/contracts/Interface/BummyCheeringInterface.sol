// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface BummyCheeringInterface {
     
    //* BummyCheering
    function setBummyInfoAddress(address _address) external;
    function isReadyToCheer(uint256 _bummyId) external view returns (bool);
    /**
     * @notice 두 token이 응원이 가능한 상태인지 조회합니다.
     * @param _momId 엄마 토큰의 경우 QR을 보여주는 토큰
     * @param _dadId 아빠 토큰의 경우 QR을 찍은 토큰
     */
    function canCheerWith(uint256 _momId, uint256 _dadId) external view returns(bool); 

    /**
     * @notice 두 token이 응원합니다!
     * @param _momId 엄마 토큰의 경우 QR을 보여주는 토큰
     * @param _dadId 아빠 토큰의 경우 QR을 찍은 토큰
     */
    function cheerWith(uint256 _momId, uint256 _dadId) external;

    /**
     * @notice 엄마 토큰의 경우 QR이 찍히고(응원이 끝나고 나서) 탈진이 끝나고 새로운 버미를 데리고 옵니다.
     * 새로운 버미는 다른 버미들과 응원할 수 있습니다.
     * @param _momId 엄마 토큰의 경우 QR을 보여주는 토큰
     */
    function inviteFriend(uint256 _momId) external returns(uint256);


}