// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract ERC223Recipient {
    event TokenReceived(address, uint, bytes);

    function tokenReceived(address _from, uint _value, bytes memory _data) public {
        emit TokenReceived(_from, _value, _data);
    }
}

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

    function transferFrom(address from, address to, uint256 tokenId) public {
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
            ERC223Recipient(to).tokenReceived(from, tokenId, data);
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