// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "hardhat/console.sol";

contract BusinessCardNFT is ERC721Enumerable, Ownable {
    // 최초 1회에 한 해 10장 발행 허용
    uint256 public initialCardSupply = 10;

    // 이후 1ETH를 지불하면 10장씩 발행 허용
    uint256 public subsequentCardSupply = 10;
    uint256 private _successCode = 0;
    uint256 public mintCost = 1 ether;

    // name, symbol
    constructor() ERC721("BusinessCardNFT", "BCNFT") {}

    struct UserInfo {
        string name;
        string organization;
        string contact;
    }

    mapping(address => uint256) public mintableCounts;
    mapping(address => UserInfo) public userInfos;

    modifier isPositiveValue(uint256 value) {
        require(value > 0, "Value must be positive");
        _;
    }

    modifier hasSavedInfo(address user) {
        require(
            !isEmptyString(userInfos[user].name) &&
                !isEmptyString(userInfos[user].organization) &&
                !isEmptyString(userInfos[user].contact),
            "You must save your information first"
        );
        _;
    }

    modifier isNotRegistered(address user) {
        require(
            isEmptyString(userInfos[user].name) &&
                isEmptyString(userInfos[user].organization) &&
                isEmptyString(userInfos[user].contact),
            "You are already registered"
        );
        _;
    }

    // GPT-driven...
    function isEmptyString(string memory str) internal pure returns (bool) {
        bytes memory tempEmptyStringTest = bytes(str);
        return tempEmptyStringTest.length == 0;
    }

    function saveUserInfo(UserInfo memory userInfo) external returns (uint256) {
        if (!isEmptyString(userInfo.name)) {
            setUsername(_msgSender(), userInfo.name);
        }

        if (!isEmptyString(userInfo.organization)) {
            setOrganization(_msgSender(), userInfo.organization);
        }

        if (!isEmptyString(userInfo.contact)) {
            setContact(_msgSender(), userInfo.contact);
        }
    }

    function setUsername(address user, string memory username) internal {
        userInfos[user].name = username;
    }

    function setOrganization(address user, string memory organization)
        internal
    {
        userInfos[user].organization = organization;
    }

    function setContact(address user, string memory contact) internal {
        userInfos[user].contact = contact;
    }

    /*
     * @description 최초 1회에 한해 10장을 mint할 수 있는 권한을 부여
     */
    function initialRegister()
        external
        hasSavedInfo(_msgSender())
        isNotRegistered(_msgSender())
    {
        mintableCounts[_msgSender()] = initialCardSupply;
    }

    function setMintCost(uint256 _mintCost) external onlyOwner {
        mintCost = _mintCost;
    }

    function deposit() external payable isPositiveValue(msg.value) {}
}
