// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Bank
 * @dev User send the Eth to the Contract and the contract would stake it to the Compound and would get the return
   with comission in between.
   Write the function modifiers that allows only owner to call the underlying method of transfering the eth to ceth
   Now have to see how to mint user added eth to 

   
 */
interface Erc20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);
}

interface CErc20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);
}

interface CEth {
    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);
}

contract Bank {
    address payable owner;
    uint256 public total_collection;
    event Sucess(address from, uint256 amount);
    event Sent(address from, address to, uint256 amnt);

    error InsufficientBalance(uint256 requested, uint256 avilable);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner is allowed to call this function"
        );
        _;
    }

    mapping(address => uint256) private userAmount;
    event MyLog(string, uint256);

    function supplyErc20ToCompound(
        // address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) public onlyOwner returns (uint256) {
        // Createating  reference to the underlying asset contract, like DAI.
        // Erc20 underlying = Erc20(_erc20Contract);

        // Create a reference to the corresponding cToken contract, like cDAI
        CErc20 cToken = CErc20(_cErc20Contract);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up)", supplyRateMantissa);

        // Approve transfer on the ERC20 contract
        // underlying.approve(_cErc20Contract, _numTokensToSupply);

        // Mint cTokens
        uint256 mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }

    // first open the bank account that would be store their address
    function openAcc(address _address, uint256 _ammount) external {
        require(_address != owner, "Bank Owner cannot Call");
        require(_ammount >= 1 ether, "Minimum 1 eth required");
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
}
