// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.19;

contract MyToken{
    address public owner;
    string public name="Piggy Token";
    string public symbol="PGT";
    uint8 public decimals = 18;
    uint256 public cap = 21_000_000 * 1e18;
    uint256 public totalSupply;
    bool public paused=false;
    uint256 public currentSnapshotId;
    uint256 public taxPercent = 2;
    address public treasury;

    mapping(uint256=>mapping(address=>uint256)) public snapshots;
    mapping(address=>uint256) public balances;
    mapping(address=>mapping(address=>uint256)) public allowance;

    event Transfer(address indexed from , address indexed to , uint256 amount);
    event Approval(address indexed owner , address indexed spender , uint256 amount);
    modifier _isOwner(){
        require(msg.sender==owner,"Get the fuck out of here");
        _;
    }
    modifier _notIsPaused(){
        require(!paused,"Sorry , wait");
        _;
    }
    constructor(uint256 _totalsupply){
        require(_totalsupply <= cap, "Cap exceeded");
        totalSupply = _totalsupply;
        balances[msg.sender] = totalSupply;
    }
    function pause() public _isOwner(){
        paused = true;
    }
    function unpause() public _isOwner(){
        paused = false;
    }

    function snapshot() public _isOwner returns (uint256) {
        currentSnapshotId += 1;
        return currentSnapshotId;
    }
    function _updateSnapshot(address user) internal {
        snapshots[currentSnapshotId][user] = balances[user];
    }

    function _mint(address _to, uint256 _amount) internal _notIsPaused{
        totalSupply += _amount;
        balances[_to] += _amount;
    }
    function _getRatePerToken() internal view  returns (uint256){
         require(totalSupply > 0, "No tokens exist yet");
         return address(this).balance*(10**decimals) / totalSupply;
    }
    
    function mint() public payable _notIsPaused {
        require(msg.value > 0, "Send ETH to mint tokens");

        uint256 rate = _getRatePerToken();
        require(rate > 0, "Token price cannot be zero");
        uint256 tokensToMint = msg.value /rate;
        require(tokensToMint > 0, "Not enough ETH sent");
        require(totalSupply + tokensToMint <= cap, "Cap exceeded");
        _mint(msg.sender, tokensToMint);
    }

    function burn(uint256 amount) public  _notIsPaused returns (bool){
            require(balances[msg.sender] >= amount, "Insufficient");

            uint256 tax = (amount * taxPercent) / 100;
            uint256 net = amount - tax;
            
            balances[msg.sender] -= amount;
            totalSupply -= amount;
            balances[address(0)] +=net;
            balances[treasury]+=tax;
            emit Transfer(msg.sender,  address(0), amount);
            return true;
    }

    function transfer(address _to , uint256 _value) public _notIsPaused returns (bool){
        require(balances[msg.sender]>=_value , "You wanna steal?");
        require(_to != address(0), "Cannot send to zero address");
        _updateSnapshot(msg.sender);
        _updateSnapshot(_to);

        uint256 tax = (_value * taxPercent) / 100;
        uint256 net = _value - tax;


        balances[msg.sender]-=_value;
        balances[_to] +=net;
        balances[treasury]+=tax;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address _spender , uint256 _value) public _notIsPaused returns (bool){
        require(balances[msg.sender]>=_value , "You kidding me?");
        require(_value == 0 || allowance[msg.sender][_spender] == 0, "Reset first");
        allowance[msg.sender][_spender]+=_value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(address _from , address _to , uint256 _value) public _notIsPaused returns (bool){
        require(balances[_from]>=_value , "THIEF");
        require(allowance[_from][msg.sender]>=_value , "THEIF AGAIN");
        _updateSnapshot(_from);
        _updateSnapshot(_to);
        uint256 tax = (_value * taxPercent) / 100;
        uint256 net = _value - tax;

        balances[_from]-=_value;
        balances[_to]+=net;
        balances[treasury]+=tax;
        allowance[_from][msg.sender]-=_value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}