pragma solidity ^0.4.10;

import "./OsaToken.sol";
import "./Crowdsale.sol";
import "./Ownable.sol";

contract Presale is Ownable {

    using SafeMath for uint;

    address public multisig;
    uint public course;
    OsaToken public token; //Token contract
    Crowdsale public crowdsale; // Crowdsale contract
    bool public presaleStopped;

    uint256 public saleSupply = 2288888888 * 1 ether;

    function Presale(address _multisig) public {
        multisig = _multisig;
        course = 200000000000000;
        token = new OsaToken();
        presaleStopped = false;
    }

    function stopPresale() onlyOwner public returns(bool) {
        presaleStopped = true;
    }

    function startCrowdsale() onlyOwner public returns(bool) {
        require(presaleStopped);
        crowdsale = new Crowdsale(multisig, token, saleSupply);
        token.transfer(address(crowdsale), token.balanceOf(this));
        token.transferOwnership(address(crowdsale));
        crowdsale.transferOwnership(owner);
        return true;
    }

    function createTokens() payable public {
        require(presaleStopped == false);
        require(msg.value >= 1 ether);
        uint256 tokens = msg.value.mul(1 ether).div(course);
        require(saleSupply >= tokens);
        saleSupply = saleSupply.sub(tokens);
        multisig.transfer(msg.value);
        token.transfer(msg.sender, tokens);
    }

    function() external payable {
        createTokens();
    }

}
