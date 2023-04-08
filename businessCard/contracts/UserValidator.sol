// SPDX-License-Identifier: UNLICENSED
contract UserValidator {
    struct UserInfo {
        string name;
        string organization;
        string contact;
        bool isRegistered;
    }
    mapping(address => UserInfo) public userInfos;

    function isEmptyString(string memory str) internal pure returns (bool) {
        bytes memory tempEmptyStringTest = bytes(str);
        return tempEmptyStringTest.length == 0;
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
            userInfos[user].isRegistered == false,
            "You are already registered"
        );
        _;
    }
}
