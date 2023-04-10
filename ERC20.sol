// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from,address indexed to,uint256 value);

  event Approval(address indexed owner,address indexed spender,uint256 value);
}

contract Coins is IERC20 {

  string private symbol;
  string private name;
  uint8  private decimals;
  address private owner;
  mapping (address => uint256) private balances;
  mapping (address => mapping (address => uint256)) private allowed;
  uint256 private TotalSupply;

    constructor(string memory _symbol, string memory _name,uint8 _decimals){
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        TotalSupply = 1000;
        owner = msg.sender;
        balances[msg.sender] = TotalSupply;
        emit Transfer(address(0), msg.sender, TotalSupply);
    }
  
  function getName() external view returns (string memory) {
    return name;
  }

   function getSymbol() external view returns (string memory) {
    return symbol;
  }
 
  function totalSupply() external view returns (uint256) {
    return TotalSupply;
  }

  function balanceOf(address _owner) external view returns (uint256) {
    return balances[_owner];
  }

  function allowance(address _owner,address _spender) external view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender],"not enough token");
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool){
    require(_value <= balances[msg.sender], "not enough token");
    allowed[msg.sender][_spender] = _value;
    emit Approval( _spender ,owner , _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    require(balances[_from] >= _value, "not enough token at owner");
    require(allowed[_from][msg.sender]>= _value, "not enough token approved");
    allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
    balances[_from] -= _value;
    balances[_to] += _value;
    emit Transfer(_from , _to , _value);
    return true;
  }
  
  function mint(address _to, uint256 _value) public returns (bool) {
    require(owner == msg.sender, "Unauthorized");
    TotalSupply += _value;
    balances[_to] += _value; 
    emit Transfer(address(0), _to , _value);  
    return true;
  }
   function _burn(address _account, uint256 _amount) external {
    require(_account == msg.sender, "not authorized");
    require(_amount <= balances[_account]);
    TotalSupply = TotalSupply - _amount;
    balances[_account] = balances[_account] - _amount;
    emit Transfer(_account, address(0), _amount);
  }
}
