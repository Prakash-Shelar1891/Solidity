pragma solidity ^0.8.0;

import "./PlayerInterface.sol";

contract AuctionManager{
    
    address manager;
    
    uint endTime;

    mapping(address => PlayerInterface[]) players;
    mapping(uint => address) Bidplayer;
    mapping(address => uint)playerPrice;
    uint counter;
    mapping(uint => address) bidders;
    mapping(address => address[]) Team;
    
    event playerCreated(string playerName, address playerAddress, string country, string Type, uint performance, uint basePrice);
    //event GetPlayer(string playerName, address playerAddress, string country, string Type, uint performance, uint basePrice);
    //event playerSold(string playerName, address playerAddress, uint atPrice);
    
    modifier timeCheck() {
        require(block.timestamp <= endTime, "Bidding is ended");
        _;
    }
    
    modifier managerCheck() {
        require(msg.sender == manager, "You are not the Manager");
        _;
    }
    
    modifier playerCheck(address _playerAddress) {
        require(_playerAddress != address(0), "Player is already registered");
        _;
    }
    
    constructor(){
        manager = msg.sender;
    }
    
    // Register new Player 
    function registerPlayer(string memory _playerName, address _playerAddress, string memory _country, string memory _Type, uint _performance, uint _basePrice) public managerCheck playerCheck(_playerAddress){
        PlayerInterface player = new PlayerInterface(_playerName, _playerAddress, _country, _Type, _performance, _basePrice);
        players[_playerAddress].push(player);
        
        counter++;
        Bidplayer[counter] = _playerAddress; // Used for getting player for Bidding
        
        // Map all players with their address and Base Price
        playerPrice[_playerAddress] = _basePrice;
        emit playerCreated(_playerName, _playerAddress, _country, _Type, _performance, _basePrice);
    }
    
    // Display player contract address
    function getPlayer(address _playerAddress) public view returns(PlayerInterface[] memory){
        return players[_playerAddress];
    }
    
    // Manager Start Bid for perticular Player and for certain Time limit
    function startBid(address _bidFor, uint _biddingTime) public managerCheck{
        require(bidFor == _bidFor, "Get players for Bidding");
        endTime = block.timestamp + _biddingTime;
    }
    
    // Get Player for Bidding
    address public bidFor;
    uint public bidPlayerBasePrice;
    function getPlayerForBid(uint _count) public managerCheck{
        bidFor = Bidplayer[_count];
        bidPlayerBasePrice = playerPrice[bidFor];
    }
    
    uint public max = 0;
    function Bid(uint _amt)public timeCheck{
        require(_amt > max, "Bid Amount must be high than prev bidder");
        require(_amt > bidPlayerBasePrice, "Bid Amount must be Higher than Players Base Price");
        require(_amt <= msg.sender.balance, "Your balance is low");
        bidders[_amt] = msg.sender;
        max = _amt;
    }
    
    // Get which Bidder Bid max
    function getMaxBid()public view returns(address){
        return bidders[max];
    }
    
    // Winner will buy player by transfering bid Amount to player
    function buyPlayer()public payable{
        require(block.timestamp > endTime, "Bidding is not ended");
        require(getMaxBid() == msg.sender, "You are not the winner");
        require(msg.value == max, "Please Enter Correct Bid Amount");
        
        Team[getMaxBid()].push(bidFor);
        payable(bidFor).transfer(msg.value); // Money transfer to Player from winner Bidder
        
        // make all state variable to zero for next players auction.
        max = 0;
        bidFor = address(0);
        bidPlayerBasePrice = 0;
    }
    
    function getTeam(address _bidderAddress) public view returns(address[] memory){
        return Team[_bidderAddress];
    }
}