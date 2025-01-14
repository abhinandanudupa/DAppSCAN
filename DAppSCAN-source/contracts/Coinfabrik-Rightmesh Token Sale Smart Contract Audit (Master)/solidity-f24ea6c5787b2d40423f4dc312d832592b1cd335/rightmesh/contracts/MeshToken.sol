// SWC-102-Outdated Compiler Version: L2
pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/ERC20/CappedToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';

/**
 * CappedToken token is Mintable token with a max cap on totalSupply that can ever be minted.
 * PausableToken overrides all transfers methods and adds a modifier to check if paused is set to false.
 */
contract MeshToken is CappedToken, PausableToken {
  string public name = "RIGHTMESH TOKEN";
  string public symbol = "RMESH";
  uint8 public decimals = 18;
  uint256 public cap = 1000000 ether;

  /**
   * @dev variable to keep track of what addresses are allowed to call transfer functions when token is paused.
   */
  mapping (address => bool) public allowedTransfers;

  /**
   * @dev variable to keep track if token has been paused once in its lifetime.
   */
  bool public pausedOnce = false;

  /*------------------------------------constructor------------------------------------*/
  /**
   * @dev constructor for mesh token
   */
  function MeshToken() CappedToken(cap) public {}

  /*------------------------------------overridden methods------------------------------------*/
  /**
   * @dev Overridder modifier to allow exceptions for pausing for a given address
   * This modifier is added to all transfer methods by PausableToken and only allows if paused is set to false.
   * With this override the function allows either if paused is set to false or msg.sender is allowedTransfers during the pause as well.
   */
  modifier whenNotPaused() {
    require(!paused || allowedTransfers[msg.sender]);
    _;
  }

  /**
   * @dev overriding Pausable#pause method to only allow pausing the contract once
   * Once unpaused token can not be paused again
   * adding this to limit owner's ability to pause the token in future.
   */
  function pause() onlyOwner whenNotPaused public {
    require(pausedOnce == false);
    pausedOnce = true;
    super.pause();
  }

  /*------------------------------------new methods------------------------------------*/

  /**
   * @dev method to updated allowedTransfers for an address
   * @param _address that needs to be updated
   * @param _allowedTransfers indicating if transfers are allowed or not
   * @return boolean indicating function success.
   */
  function updateAllowedTransfers(address _address, bool _allowedTransfers)
  external
  onlyOwner
  returns (bool)
  {
    // don't allow owner to change this for themselves
    // otherwise whenNotPaused will not work as expected for owner,
    // therefore prohibiting them from calling pause/unpause.
    require(_address != owner);

    allowedTransfers[_address] = _allowedTransfers;
    return true;
  }
}
