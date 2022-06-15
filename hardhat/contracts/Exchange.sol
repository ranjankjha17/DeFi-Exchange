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

}

