// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return balance The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return owner The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address owner);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return _approved The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address _approved);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721Receiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external ;
}

contract ERC223Recipient is IERC721Receiver {
    event TokenReceived(address, address, uint, bytes);

    function onERC721Received(address _operator,address _from,uint256 _tokenId,bytes memory _data) external override  {
        emit TokenReceived(_operator, _from, _tokenId, _data);
    }
}

/// @notice MyNFT is an NFT contract
contract MyNFT is IERC721, IERC165 {
    string private _name;
    string private _symbol;

    mapping (address => uint256) internal ownedTokens;
    mapping (uint256 => address) internal tokenOwner;
    mapping (address => uint256) internal ownedTokensCount;
    mapping (address => mapping (address => bool)) operatorApprovals;
    mapping (uint256 => address) tokenApprovals;

    constructor(string memory nameValue, string memory symbolValue) {
        _name = nameValue;
        _symbol = symbolValue;
    }

    function name() public view  returns (string memory) {
        return _name; 
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view override returns (uint256 balance) {
        return ownedTokensCount[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address owner) {
        return tokenOwner[tokenId];
    }

    function mint(address to, uint256 tokenId) external {
        require( to != address(0), "address cannot be default null address");
        require(tokenId > 0, "token id cannot be zero or less!");
        ownedTokens[to] += 1;
        tokenOwner[tokenId] = to;
        ownedTokens[to] = tokenId;

        emit Transfer(msg.sender, to, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(tokenId > 0, "token id cannot be zero or less!");
        address from = ownerOf(tokenId);
        tokenApprovals[tokenId] = address(0);
        ownedTokensCount[from] = ownedTokensCount[from] - 1;
        delete tokenOwner[tokenId];
        delete ownedTokens[from];
        emit Transfer(from, address(0), tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable {
        require(from != address(0), "from address cannot be default null address");
        require(to != address(0), "from address cannot be default null address");
        require(tokenId > 0, "token id cannot be zero or less!");
        require(ownedTokensCount[from] > 0, "from address should own a token!");
        require(tokenOwner[tokenId] == from, "from address should own a token!");
        ownedTokensCount[from] = ownedTokensCount[from] - 1;
        ownedTokensCount[to] = ownedTokensCount[to] + 1;

        tokenOwner[tokenId] = address(0);
        tokenApprovals[tokenId] = address(0);
        tokenOwner[tokenId] = to;
        ownedTokens[to] = tokenId;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        uint256 length;
        assembly {
            length := extcodesize(to)
        }
        transferFrom(from, to, tokenId);
        if (length > 0) {
            ERC223Recipient(to).onERC721Received(msg.sender ,from, tokenId, data);
        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function approve(address spender, uint256 tokenId) external override {
        require(tokenId > 0, "token id cannot be zero or less!");
        require(spender != address(0), "spender address cannot be default null address");
        address owner = tokenOwner[tokenId];
        require(msg.sender == owner || operatorApprovals[owner][msg.sender], "not owner nor approved for all");
        tokenApprovals[tokenId] = spender;
        emit Approval(owner, spender, tokenId);
    }

    function setApprovalForAll(address operator,bool _approved) external override {
        require(operator != address(0), "operator address cannot be default null address");
        operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function getApproved(uint256 tokenId) public view override returns (address operator) {
        return tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner,address operator) public view override returns (bool) {
        return operatorApprovals[owner][operator];
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}