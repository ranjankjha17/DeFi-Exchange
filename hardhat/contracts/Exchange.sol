//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public cryptoDevTokenAddress;

    //Exchange is inheriting ERC20, because our exchange would keep track of Crypto Dev LP tokens
    constructor(address _CryptoDevToken) ERC20("CryptoDev LP Token", "CDLP"){
        require(_CryptoDevToken!=address(0),"Token address passed is a null address");
        cryptoDevTokenAddress=_CryptoDevToken;
    }

    //Returns the amount of `Crypto Dev Tokens` held by the contract
    function getReserve() public view returns(uint){
        return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
    }

    //Adds liquidity to the exchange
    function addLiquidity(uint _amount) public payable returns(uint){
        uint liquidity;
        uint ethBalance=address(this).balance;
        uint cryptoDevTokenReserve=getReserve();
        ERC20 cryptoDevToken=ERC20(cryptoDevTokenAddress);

        if(cryptoDevTokenReserve==0){
            // Transfer the `cryptoDevToken` from the user's account to the contract
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);

            liquidity=ethBalance;
            _mint(msg.sender,liquidity);
        }else{

            uint ethReserve=ethBalance - msg.value;

            uint cryptoDevTokenAmount=(msg.value * cryptoDevTokenReserve)/(ethReserve);

            require(_amount >= cryptoDevTokenAmount,"Amount of tokens sent is less than the minimum tokens required");

            cryptoDevToken.transferFrom(msg.sender,address(this), cryptoDevTokenAmount);

            liquidity=(totalSupply() *msg.value)/ethReserve;

            _mint(msg.sender,liquidity);

        }
        return liquidity;
    }

    // Returns the amount Eth/Crypto Dev tokens that would be returned to the user in the swap
    function removeLiquidity(uint _amount) public returns(uint,uint){
        require(_amount>0,"_amount should be greater than zero");
        uint ethReserve=address(this).balance;
        uint _totalSupply=totalSupply();

        // The amount of Eth that would be sent back to the user is based
        uint ethAmount=(ethReserve * _amount)/_totalSupply;
        // The amount of Crypto Dev token that would be sent back to the user is based
        // on a ratio

        uint cryptoDevTokenAmount=(getReserve() * _amount)/_totalSupply;

        // Burn the sent LP tokens from the user's wallet because they are already sent to
        // remove liquidity

        _burn(msg.sender,_amount);
        // Transfer `ethAmount` of Eth from user's wallet to the contract
        payable(msg.sender).Transfer(ethAmount);
        // Transfer `cryptoDevTokenAmount` of Crypto Dev tokens from the user's wallet to the contract
        ERC20(cryptoDevTokenAddress).Transfer(msg.sender,cryptoDevTokenAmount);
        return (ethAmount,cryptoDevTokenAmount);

    }

    // Returns the amount Eth/Crypto Dev tokens that would be returned to the user in the swap

    function getAmountOfTokens(uint256 inputAmount,uint256 inputReserve,uint256 outputReserve) public pure returns (uint256){
        require(inputReserve > 0 && outputReserve > 0,"Invalid Reservers");
        uint256 inputAmountWithFee=inputAmount * 99;

        uint256 numerator=inputAmountWithFee * outputReserve;

        uint256 denominator=(inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }
}

