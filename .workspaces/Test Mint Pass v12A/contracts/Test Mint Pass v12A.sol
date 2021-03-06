// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;


error NoEthBalance();

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ERC1155.sol";
import "./Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./SafeTransferLib.sol";


// import {SafeTransferLib} from "./SafeTransferLib.sol";


/// @title TestMintPassv12A
/// @author 

contract TestMintPassv12A is ERC1155, Ownable {

    /*///////////////////////////////////////////////////////////////
                            TOKEN METADATA
    //////////////////////////////////////////////////////////////*/
    string public name;
    string public symbol;
    address public vaultAddress;

    /*///////////////////////////////////////////////////////////////
                            TOKEN DATA
    //////////////////////////////////////////////////////////////*/
    uint256 public immutable Test_Mint_Pass_BlackMaxSupply = 1500;
    uint256 public immutable Test_Mint_Pass_BlueMaxSupply = 1550;
    uint256 public immutable Test_Mint_Pass_BlackGiveawayTotal = 1500;
    uint256 public immutable Test_Mint_Pass_BlueGiveawayTotal = 1500;

    uint256 public immutable Test_Mint_Pass_BlackTokenId = 1;
    uint256 public immutable Test_Mint_Pass_BlueTokenId = 2;
    uint256 public constant Test_Mint_Pass_Black = 1;
    uint256 public constant Test_Mint_Pass_Blue = 2;

    /*///////////////////////////////////////////////////////////////
                            STORAGE
    //////////////////////////////////////////////////////////////*/
    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256 => string) public tokenURI;
    mapping(address => uint256) public TestMintPassBlueMinted;
    mapping(address => uint256) public TestMintPassBlackMinted;

    /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        string memory _name,
        string memory _symbol,
        address _vaultAddress,
        string memory _TestMintPassBlackTokenUri,
        string memory _TestMintPassBlueTokenUri
    ) {
        _name = "Test Mint Pass v12A";
        _symbol = "&#10047;TMPV10I";
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, 0x4E322A20eD891fF77De2F774d2824F55B7152C73);
        _vaultAddress = 0xC83BeBa473Dd6Bd1890519Ee0EEe2aC4Fa5836B5;
        _TestMintPassBlueTokenUri = "ipfs://QmcF3UrWPvyn95QW1Bu92Zj6UvFZ9SJGU8FmpFXFd6exeH";
        _TestMintPassBlackTokenUri = "ipfs://QmQPHEhnjtRGo2mhuGVpUhUqzpqZM773baiCRt6AYVn8yk";
    }

    /// @notice totalSupply of a token ID
    /// @param id is the ID, either generalTokenId or blackTokenId
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }


    /*///////////////////////////////////////////////////////////////
                        ownerOnly FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /// @notice function to change the tokenURI
    /// @param _newTokenURI this is the new token uri
    /// @param tokenId this is the token ID that will be set
    function setTokenURI(string memory _newTokenURI, uint256 tokenId)
        public onlyOwner
    {
        tokenURI[tokenId] = _newTokenURI;
    }

    /// @notice function for owner to mint (LC)
    /// @param to address to mint it to.
    function mintGiveaway(address to) public onlyOwner {
        // mint black
        _mint(to, Test_Mint_Pass_BlackTokenId, Test_Mint_Pass_BlackGiveawayTotal, "");
        // mint general
        _mint(to, Test_Mint_Pass_BlueTokenId, Test_Mint_Pass_BlueGiveawayTotal, "");
    }

    /// @notice function for owner to mint the token,
    /// just in case it's needed, mintGiveaway() will be used to mint all the giveaways
    /// @param to address to mint it to.
    /// @param amount the amount that the owner wants to mint.
    /// @param tokenId which token ID 1 for black 2 for general
    function ownerMint(
        address to,
        uint256 amount,
        uint256 tokenId
    ) public onlyOwner {
        require(
            tokenId == Test_Mint_Pass_BlueTokenId || tokenId == Test_Mint_Pass_BlackTokenId,
            "TMPV12A: Nonexistent token ID."
        );

        if (tokenId == Test_Mint_Pass_BlueTokenId) {
            require(
                amount + totalSupply(Test_Mint_Pass_BlueTokenId) <= Test_Mint_Pass_BlueMaxSupply,
                "TMPV12A: Amount is larger than totalSupply."
            );
            _mint(to, tokenId, amount, "");
        } else {
            require(
                amount + totalSupply(Test_Mint_Pass_BlackTokenId) <= Test_Mint_Pass_BlackMaxSupply,
                "TMPV12A: Amount is larger than totalSupply."
            );
            _mint(to, tokenId, amount, "");
        }
    }

    /*///////////////////////////////////////////////////////////////
                            ETH WITHDRAWAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Withdraw all ETH from the contract to the vault address.
    function withdraw() public onlyOwner {
        if (address(this).balance == 0) revert NoEthBalance();
        SafeTransferLib.safeTransferETH(vaultAddress, address(this).balance);
    }

    /// @notice changing vault address
    /// @param _vaultAddress is the new vaultAddress
    function setVault(address _vaultAddress) public onlyOwner {
        vaultAddress = _vaultAddress;
    }

    /// @notice returns the token URI
    /// @param tokenId which token ID to return 1 or 2.
    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (bytes(tokenURI[tokenId]).length == 0) {
            return "";
        }

        return tokenURI[tokenId];
    }


}
