// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Bank
 * @dev User send the Eth to the Contract and the contract would stake it to the Compound and would get the return
   with comission in between.
   
 */
contract Bank {
    // struct UserInfo = {
    //     address userAddr;
    //     uint userFund;
    // }
    // 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    // []UserInfo private aboutUser
    address private owner;
    uint256 public total_collection;
    event Sucess(address from, uint256 amount);
    event Sent(address from, address to, uint256 amnt);

    error InsufficientBalance(uint256 requested, uint256 avilable);

    constructor() {
        owner = msg.sender;
    }

    mapping(address => uint256) private userAmount;

    // first open the bank account that would be store their address
    function openAcc(address _address, uint256 _ammount) external {
        require(_address != owner, "Bank Owner cannot Call");
        require(_ammount >= 1, "Minimum 1 eth required");
        userAmount[_address] = _ammount;
        total_collection += _ammount;
        emit Sucess(_address, _ammount);
    }

    // to check which address have the how much value

    function getBalance(address _address) public view returns (uint256) {
        return userAmount[_address];
    }

    function transfer(
        address _from,
        address _to,
        uint256 _ammount
    ) external {
        if (_ammount > userAmount[_from])
            revert InsufficientBalance({
                requested: _ammount,
                avilable: userAmount[_from]
            });
        userAmount[_from] -= _ammount;
        userAmount[_to] += _ammount;
        emit Sent(_from, _to, _ammount);
    }

    // 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
}
