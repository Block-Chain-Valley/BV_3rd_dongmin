// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "hardhat/console.sol";

import "./UserValidator.sol";

contract BusinessCardNFT is ERC721Enumerable, Ownable, UserValidator {
    // 최초 1회에 한 해 10장 발행 허용
    uint256 public initialCardSupply = 10;
    // 이후 1ETH를 지불하면 10장씩 발행 허용
    uint256 public mintCost = 1 ether;
    uint256 public subsequentCardSupply = 10;

    uint256 public organizationAuthCost = 2 ether;
    string public organizationName = "BlockChainValley";

    UserInfo[] public cards;
    mapping(address => uint256) public balances;

    // name, symbol
    constructor() ERC721("BusinessCardNFT", "BCNFT") {}

    mapping(address => uint256) public mintableCounts;

    mapping(address => UserInfo) public organizationMembers;

    modifier isPositiveValue(uint256 value) {
        require(value > 0, "Value must be positive");
        _;
    }
    modifier hasSufficientAuthCost(address user) {
        require(
            balances[user] >= organizationAuthCost,
            "You don't have enough balance to mint"
        );
        _;
    }

    // 명함 제작에 필요한 유저 정보를 기록합니다.
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

    /*
     * @description 최초 1회에 한해 10장을 mint할 수 있는 권한을 부여
     */
    function register()
        external
        hasSavedInfo(_msgSender())
        isNotRegistered(_msgSender())
    {
        userInfos[_msgSender()].isRegistered = true;
        mintableCounts[_msgSender()] = initialCardSupply;
    }

    // 이후 유저는 1 ETH를 지불하여 자신의 명함 10장을 얻을 수 있습니다.
    function mintBusinessCard(uint256 amount) external payable {
        if (amount <= mintableCounts[_msgSender()]) {
            for (uint256 i = 0; i < amount; i++) {
                _safeMint(_msgSender(), totalSupply() + 1);

                cards[cards.length + 1] = userInfos[_msgSender()];
            }
            mintableCounts[_msgSender()] -= amount;
        } else {
            require(
                balances[_msgSender()] >= mintCost,
                "You don't have enough balance to mint"
            );
            balances[_msgSender()] -= mintCost;
            mintableCounts[_msgSender()] += subsequentCardSupply;

            for (uint256 i = 0; i < amount; i++) {
                _safeMint(_msgSender(), totalSupply() + 1);

                cards[cards.length + 1] = userInfos[_msgSender()];
            }

            mintableCounts[_msgSender()] -= amount;
        }
    }

    // 명함 발급 비용은 owner가 변경할 수 있습니다.
    function setMintCost(uint256 _mintCost) external onlyOwner {
        mintCost = _mintCost;
    }

    // 명함은 NFT이므로 유저는 타인에게 NFT를 transfer할 수 있습니다.
    function transferBusinessCard(address to, uint256 tokenId)
        external
        hasSavedInfo(_msgSender())
    {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _transfer(_msgSender(), to, tokenId);
    }

    // 컨트랙트에 예치하면
    function deposit() external payable isPositiveValue(msg.value) {
        uint256 amount = msg.value;

        balances[_msgSender()] += amount;
    }

    // 2ETH를 예치하면 조직의 권한을 얻을 수 있습니다.
    function authorizeAsOrganization()
        external
        hasSufficientAuthCost(_msgSender())
        hasSavedInfo(_msgSender())
    {
        organizationMembers[_msgSender()] = userInfos[_msgSender()];
    }

    function mintOrganizationBusinessCards(uint256 amount) external onlyOwner {
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(_msgSender(), totalSupply() + 1);

            cards[cards.length + 1] = UserInfo(
                userInfos[_msgSender()].name,
                organizationName,
                userInfos[_msgSender()].contact,
                userInfos[_msgSender()].isRegistered
            );
        }
    }

    //// internal functions
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
}
