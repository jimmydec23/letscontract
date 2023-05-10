// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/// @notice ERC20 interface
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/// @notice MyToken is ERC20 token
contract MyToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping ( address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    uint256 _totalSupply;
    address payable owner;

    constructor(uint256 supply) {
        name = "MyToken";
        symbol = "MYT";
        decimals = 18;

        // total supply can be set by contract creator
        _totalSupply = supply;

        // contract creator own all token supply at the beginning
        owner = payable(msg.sender);
        balances[msg.sender] = _totalSupply;
    }

    /// @notice check token total supply
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /// @notice check token owner balance
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /// @notice transfer token from msg.sender to others
    /// @param _to who receive token
    /// @param _value transfer amount
    /// @return success transfer result
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice msg.sender transfer token from token owner to other people
    /// @param _from token owner
    /// @param _to token receiver
    /// @param _value token amount
    /// @return success transfer result
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        // both owner and spender's balance should be handle well
        balances[_from] = balances[_from] - _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        return true;
    }

    /// @notice give ownership of msg.sender's token to spender
    /// @param _spender the spender who can use msg.sender's token
    /// @param _value amount of token
    /// @return success approve result
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @notice check how many token the spender can use
    /// @param _owner token owner
    /// @param _spender token spender
    /// @return remaining token amount
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}