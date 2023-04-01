// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
 
import "./BummyAccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Interface/BummyBaseInterface.sol";
contract BummyBase is BummyAccessControl, ERC721Enumerable,BummyBaseInterface {

    /// @notice Name and symbol of the non fungible token, ad defined in ERC721
    string _name = "BummyNFT";
    string _symbol = "BV";

    constructor() ERC721 (_name, _symbol) {}

    event Birth(address indexed owner, uint256 BummyId, uint256 momId, uint256 dadId, uint256 genes);

    /*** DATA TYPES ***/

    struct Bummy {
        // 버미 유전자
        uint256 genes;

        // 버미가 생겨난 시간
        uint64 birthTime;

        // 교배후 자식 키티가 민팅이 가능해지는 시각, 다음 교배가 가능해지는 시각
        uint64 cooldownEndTime; 
        
        uint32 MomId;
        uint32 DadId;

        // 교배 중인 BummyId
        uint32 cheeringWithId;

        //교배시 1씩 증가하며 교배 쿨타임 기간 증가
        uint8 cooldownIndex;
        //자식 수
        uint8 children;

        // 세대수, 이 값은 부모의 세대에 의해 아래와 같이 결정
        // max(mom.generation, dad.generation) + 1
        uint16 generation;
    }

    /*** CONSTANTS ***/
    // 어깨동무를 너무 많이 하는 것을 방지하기 위해 
    // cooldown 값이 교배할수록 증가함.
    uint32[8] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours)
    ];

    /*** STORAGE ***/

    /// @dev 존재하는 버미들을 저장하는 공간
    /// ID = 0인 버미는 존재할 수 없습니다.
    Bummy[] bummies;

    
    /// @dev BummyId와 owner를 mapping
    /// BummyId => siring이 허락된 address
    mapping (uint256 => address) public cheerAllowedToAddress;

    
    /// @dev _tokenId에 해당하는 Bummy를 _from에서 _to로 보냅니다.
    /// 
    function _transfer(address _from, address _to, uint256 _tokenId) override internal virtual {
       
    }

    /// @dev 버미를 생성하고 민팅합니다. 
    /// 이때, tokenId(BummyId)가 정해집니다.  
    /// @param _momId The bummy ID of the mom of this bummy (zero for gen0)
    /// @param _dadId The bummy ID of the dad of this bummy (zero for gen0)
    /// @param _generation The generation number of this bummy, must be computed by caller.
    /// @param _genes The bummy's genetic code.
    /// @param _owner The inital owner of this bummy, must be non-zero (except for the unKitty, ID 0)
    function _createBummy(
        uint256 _momId,
        uint256 _dadId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    ) internal returns (uint)
    {
        /// 세대수와 Id의 최대 가지수
        require(_momId <= 2**32 - 1);
        require(_dadId <= 2**32 - 1);
        require(_generation <= 2**16-1);
        
        
        Bummy memory _bummy = Bummy({
            genes: _genes,
            birthTime: uint64(block.timestamp),
            cooldownEndTime: 0,
            MomId: uint32(_momId),
            DadId: uint32(_dadId),
            cheeringWithId: 0,
            cooldownIndex: 0,
            children: 0,
            generation: uint16(_generation)

        });
        bummies.push(_bummy);
        uint256 newBummyId = bummies.length - 1;
        

        require(newBummyId <= 2**32 - 1 );

        // emit the birth event
        emit Birth(
            _owner,
            newBummyId,
            uint256(_bummy.MomId),
            uint256(_bummy.DadId),
            _bummy.genes
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _safeMint(_owner, newBummyId);


        return newBummyId;
    }
}

