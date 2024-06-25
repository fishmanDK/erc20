// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    constructor(string memory name_, string memory symbol_, uint initialSupply, address shop) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, shop);
    }

    modifier anoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "not anought tokens!");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function name() external view returns(string memory){
        return _name;
    }

    function symbol() external view returns(string memory){
        return _symbol;
    }

    function decimals() external pure returns(uint){
        return 18;
    }

    function totalSupply() external view returns(uint){
        return totalTokens;
    }

    function balanceOf(address account) public view returns(uint){
        return balances[account];    
    }

    function transfer(address to, uint amount) external{
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(address _owner, address spender) public view returns(uint){
        return allowances[_owner][spender];
    }
            
    function approve(address spender, uint amount) external{
        allowances[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) external anoughTokens(msg.sender, amount){
        _beforeTokenTransfer(sender, recipient, amount);

        allowances[sender][recipient] -= amount;

        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function mint(uint amount, address shop) public onlyOwner{
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function burn(address _from, uint amount) public onlyOwner{
        balances[_from] -= amount;
        totalTokens -= amount;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual{}
}

contract DDToken is ERC20{
    constructor(address shop) ERC20("DDToken", "DDT", 1000, shop){}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal override {}
}

contract MShop {
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    constructor() {
        token = new DDToken(address(this));
        owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function sell(uint _amountToSell) external{
        require(
            _amountToSell > 0 &&
            token.balanceOf(msg.sender) >= _amountToSell,
            "incorrect amount"
        );

        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "check allowance!");

        token.transferFrom(msg.sender, address(this), _amountToSell);
        payable(msg.sender).transfer(_amountToSell);

        emit Sold(_amountToSell, msg.sender);
    }

    receive() external payable {
        uint tokensToBuy = msg.value;
        require(tokensToBuy > 0, "not enough funds!");

        require(tokenBalance() >= tokensToBuy, "not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }

    function tokenBalance() public view returns(uint){
        return token.balanceOf(address(this));
    }
}