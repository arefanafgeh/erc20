// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.19;

contract MyToken{
    string public name="Piggy Token";
    string public symbol="PGT";
    uint8 public decimals = 18;

    uint256 public totalSuplly;

    mapping(address=>uint256) public balances;
    mapping(address=>mapping(address=>uint256)) public allowance;

    event Transfer(address indexed from , address indexed to , uint256 amount);
    event Approval(address indexed owner , address indexed spender , uint256 amount);
    constructor(uint256 _totalsupply){
        totalSuplly = _totalsupply;
        balances[msg.sender] = totalSuplly;
    }

    function transfer(address _to , uint256 _value) public returns (bool){
        require(balances[msg.sender]>=_value , "You wanna steal?");

        balances[msg.sender]-=_value;
        balances[_to] +=_value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function approve(address _spender , uint256 _value) public returns (bool){
        require(balances[msg.sender]>=_value , "You kidding me?");
        allowance[msg.sender][_spender]+=_value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(address _from , address _to , uint256 _value) public returns (bool){
        require(balances[_from]>=_value , "THIEF");
        require(allowance[_from][msg.sender]>=_value , "THEIF AGAIN");
        balances[_from]-=_value;
        balances[_to]+=_value;
        allowance[_from][msg.sender]-=_value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}