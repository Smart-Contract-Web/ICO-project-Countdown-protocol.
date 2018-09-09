pragma solidity ^0.4.23;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

    interface ERC20 {
        function transfer(address _beneficiary, uint256 _tokenAmount) external returns (bool);
        function transferFromICO(address _to, uint256 _value) external returns(bool);
    }

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract MainSale is Ownable {

    using SafeMath for uint;

    ERC20 public token;
    
    address Teams = 0xe3af41343b5E797f7f164c7883Bbb842797bE52a;
    address promouters = 0xBFA33ECdeCD1D2959317be0EF471CEd60bB67681;
    address bounty = 0x50DBe7eB46556dFD1D271dE3Fe4802A860132844;

    uint256 public constant decimals = 18;
    uint256 constant dec = 10**decimals;

    mapping(address=>bool) whitelist;

    uint256 public startCloseSale = now; // start // 1.10.2018 10:00 UTC
    uint256 public endCloseSale = 1540900800; // Tue, 30 Oct 2018 12:00:00 GMT

    uint256 public startStage1 = 1540900801; // Tue, 30 Oct 2018 12:00:01 GMT
    uint256 public endStage1 = 1543579200; // Fri, 30 Nov 2018 12:00:00 GMT

    uint256 public startStage2 = 1543579201; // Fri, 30 Nov 2018 12:00:01 GMT
    uint256 public endStage2 = 1546171200; // Sun, 30 Dec 2018 12:00:00 GMT

    uint256 public startStage3 = 1546171201; // Sun, 30 Dec 2018 12:00:00 GMT
    uint256 public endStage3 = 1548849600; // Wed, 30 Jan 2019 12:00:00 GMT

    uint256 public buyPrice = 10000000000000; // 0.00001 Ether
    
    uint256 public ethUSD;

    uint256 public weisRaised = 0;

    string public stageNow = "Sale";
    
    event Authorized(address wlCandidate, uint timestamp);
    event Revoked(address wlCandidate, uint timestamp);

    constructor() public {}

    function setToken (ERC20 _token) public onlyOwner {
        token = _token;
    }
    
    /*******************************************************************************
     * Whitelist's section
     */
    function authorize(address wlCandidate) public onlyOwner  {
        require(wlCandidate != address(0x0));
        require(!isWhitelisted(wlCandidate));
        whitelist[wlCandidate] = true;
        emit Authorized(wlCandidate, now);
    }

    function revoke(address wlCandidate) public  onlyOwner {
        whitelist[wlCandidate] = false;
        emit Revoked(wlCandidate, now);
    }

    function isWhitelisted(address wlCandidate) public view returns(bool) {
        return whitelist[wlCandidate];
    }
    
    /*******************************************************************************
     * Setter's Section
     */

    function setStartCloseSale(uint256 newStartSale) public onlyOwner {
        startCloseSale = newStartSale;
    }

    function setEndCloseSale(uint256 newEndSale) public onlyOwner{
        endCloseSale = newEndSale;
    }

    function setStartStage1(uint256 newsetStage2) public onlyOwner{
        startStage1 = newsetStage2;
    }

    function setEndStage1(uint256 newsetStage3) public onlyOwner{
        endStage1 = newsetStage3;
    }

    function setStartStage2(uint256 newsetStage4) public onlyOwner{
        startStage2 = newsetStage4;
    }

    function setEndStage2(uint256 newsetStage5) public onlyOwner{
        endStage2 = newsetStage5;
    }

    function setStartStage3(uint256 newsetStage5) public onlyOwner{
        startStage3 = newsetStage5;
    }

    function setEndStage3(uint256 newsetStage5) public onlyOwner{
        endStage3 = newsetStage5;
    }

    function setPrices(uint256 newPrice) public onlyOwner {
        buyPrice = newPrice;
    }
    
    function setETHUSD(uint256 _ethUSD) public onlyOwner { 
        ethUSD = _ethUSD;
    
    
    }
    
    /*******************************************************************************
     * Payable Section
     */
    function ()  public payable {
        
        require(msg.value >= (1*1e18/ethUSD*1));

        if (now >= startCloseSale || now <= endCloseSale) {
            require(isWhitelisted(msg.sender));
            closeSale(msg.sender, msg.value);
            stageNow = "Close Sale for Whitelist's members";
            
        } else if (now >= startStage1 || now <= endStage1) {
            sale1(msg.sender, msg.value);
            stageNow = "Stage 1";

        } else if (now >= startStage2 || now <= endStage2) {
            sale2(msg.sender, msg.value);
             stageNow = "Stage 2";

        } else if (now >= startStage3 || now <= endStage3) {
            sale3(msg.sender, msg.value);
             stageNow = "Stage 3";

        } else {
            stageNow = "No Sale";
            revert();
        } 
    }
    
    // issue token in a period of closed sales
    function closeSale(address _investor, uint256 _value) internal {

        uint256 tokens = _value.mul(1e18).div(buyPrice); // 68%
        uint256 bonusTokens = tokens.mul(30).div(100); // + 30% per stage
        tokens = tokens.add(bonusTokens); 
        token.transferFromICO(_investor, tokens);
        weisRaised = weisRaised.add(msg.value);

        uint256 tokensTeams = tokens.mul(15).div(68); // 15 %
        token.transferFromICO(Teams, tokensTeams);

        uint256 tokensBoynty = tokens.div(34); // 2 %
        token.transferFromICO(bounty, tokensBoynty);

        uint256 tokensPromo = tokens.mul(15).div(68); // 15%
        token.transferFromICO(promouters, tokensPromo);
    }
    
    // the issue of tokens in period 1 sales
    function sale1(address _investor, uint256 _value) internal {

        uint256 tokens = _value.mul(1e18).div(buyPrice); // 66% 

        uint256 bonusTokens = tokens.mul(10).div(100); // + 10% per stage
        tokens = tokens.add(bonusTokens); // 66 %

        token.transferFromICO(_investor, tokens);

        uint256 tokensTeams = tokens.mul(5).div(22); // 15 %
        token.transferFromICO(Teams, tokensTeams);

        uint256 tokensBoynty = tokens.mul(2).div(33); // 4 %
        token.transferFromICO(bounty, tokensBoynty);

        uint256 tokensPromo = tokens.mul(5).div(22); // 15%
        token.transferFromICO(promouters, tokensPromo);

        weisRaised = weisRaised.add(msg.value);
    }
    
    // the issue of tokens in period 2 sales
    function sale2(address _investor, uint256 _value) internal {

        uint256 tokens = _value.mul(1e18).div(buyPrice); // 64 %

        uint256 bonusTokens = tokens.mul(5).div(100); // + 5% 
        tokens = tokens.add(bonusTokens);

        token.transferFromICO(_investor, tokens);

        uint256 tokensTeams = tokens.mul(15).div(64); // 15 %
        token.transferFromICO(Teams, tokensTeams);

        uint256 tokensBoynty = tokens.mul(3).div(32); // 6 %
        token.transferFromICO(bounty, tokensBoynty);

        uint256 tokensPromo = tokens.mul(15).div(64); // 15%
        token.transferFromICO(promouters, tokensPromo);

        weisRaised = weisRaised.add(msg.value);
    }

    // the issue of tokens in period 3 sales
    function sale3(address _investor, uint256 _value) internal {

        uint256 tokens = _value.mul(1e18).div(buyPrice); // 62 %
        token.transferFromICO(_investor, tokens);

        uint256 tokensTeams = tokens.mul(15).div(62); // 15 %
        token.transferFromICO(Teams, tokensTeams);

        uint256 tokensBoynty = tokens.mul(4).div(31); // 8 %
        token.transferFromICO(bounty, tokensBoynty);

        uint256 tokensPromo = tokens.mul(15).div(62); // 15%
        token.transferFromICO(promouters, tokensPromo);

        weisRaised = weisRaised.add(msg.value);
    }

    /*******************************************************************************
     * Manual Management
     */
    function transferEthFromContract(address _to, uint256 amount) public onlyOwner {
        _to.transfer(amount);
    }
}
