// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/* 
User Would just send the hello and 1 ether to the contract and then we would send them the 10 trussCoin.
@Name of coin: TrussCoin
@Symbol: TC
@TotalSupply: 10M
@Decimals: standard ERC20 -18
@mint: 1M to deployer or owner of the contract
*/

contract MyToken {
    string NAME = "TrussCoin";
    string SYMBOL = "TC";

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // to keep record of address with their balances.
    mapping(address => uint256) balances;
    address deployer;

    constructor() {
        deployer = msg.sender;
        balances[deployer] = 1000000 * 1e18;
    }

    function name() public view returns (string memory) {
        return NAME;
    }

    function symbol() public view returns (string memory) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 10000000 * 1e18; //10M * 10^18 because decimals is 18
    }

    // Given an address of user we must return the balance of the person
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // We need to deduct the balance from one user to another.
    // and update upon both sides these changes would definetly be reflected both sides.
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        assert(balances[msg.sender] > _value);
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (balances[_from] < _value) return false;

        if (allowances[_from][msg.sender] < _value) return false;

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    mapping(address => mapping(address => uint256)) allowances;

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }
}
