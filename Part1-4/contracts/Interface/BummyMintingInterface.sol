// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface BummyMintingInterface {
    //* BummyMinting
    /**
     * @notice 홍보용 버미를 만듭니다. CEO만 실행할 수 있습니다.
     * @param _genes 엄마 토큰의 경우 QR을 보여주는 토큰
     * @param _owner 토큰 주인의 address
     */
    function createPromoBummy(uint256 _genes, address _owner) external returns (uint256);
    /**
     * @notice 사람마다 0세대 버미를 만들 수 있습니다.
     */
    function createFirstGen0Bummy() external returns (uint256);

}