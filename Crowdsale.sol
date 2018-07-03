pragma solidity ^0.4.10;

import "./OsaToken.sol";
import "./Ownable.sol";

contract Crowdsale is Ownable {

    using SafeMath for uint;

    address public multisig;
    uint public course;
    OsaToken public token; //Token contract
    uint public saleSupply;
    bool public saleStopped;
    uint public refundTimeStart;

    uint256 public RESERVED_SUPPLY = 2800000000 * 1 ether;

    function Crowdsale(address _multisig, OsaToken _token, uint _saleSupply) public {
        multisig = _multisig;
        course = 200000000000000;
        token = _token;
        saleSupply = _saleSupply;
        saleStopped = false;
        refundTimeStart = now;
    }

    modifier saleNoStopped() {
        require(saleStopped == false);
        _;
    }

    function stopSale() onlyOwner saleNoStopped public returns(bool) {
        if (saleSupply > 0) {
            token.burn(saleSupply);
        }
        saleStopped = true;
        return token.stopSale();
    }

    function createTokens() saleNoStopped payable public {
        require(msg.value >= 1 ether);
        uint256 tokens = msg.value.mul(1 ether).div(course);
        require(saleSupply >= tokens);
        saleSupply = saleSupply.sub(tokens);
        multisig.transfer(msg.value);
        token.transfer(msg.sender, tokens);
    }

    function adminSendTokens(address _to, uint256 _value) onlyOwner saleNoStopped public returns(bool) {
        require(saleSupply >= _value);
        saleSupply = saleSupply.sub(_value);
        return token.transfer(_to, _value);
    }

    function adminRefundTokens(address _from, uint256 _value) onlyOwner saleNoStopped public returns(bool) {
        saleSupply = saleSupply.add(_value);
        return token.refund(_from, _value);
    }

    function refundTeamTokens() onlyOwner public returns(bool) {
        require(now > refundTimeStart + 48 * 1 weeks && saleStopped);
        return token.transfer(msg.sender, RESERVED_SUPPLY);
    }

    function() external payable {
        createTokens();
    }

}
