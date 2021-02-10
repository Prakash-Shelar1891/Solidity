pragma solidity ^0.8.0;

contract ArtworkInterface {
    string Art_name;
    string owner_name;
    address owner;
    bytes32 hash;
    uint ArtType;
    string URL;
    uint registeredOn;
    
    address prev_Owner;
    bool sell;
    uint price;
    
    event verifyOwner(string _result);
    event verifyArt(string _result);
    event transferOwner(address _pre, address _new);
    
    event GetArtwork(
        string _artName,
        string _ownerName,
        address _owner,
        bytes32 _hash,
        uint _artType,
        string _url,
        uint _registeredOn
        );
    
    constructor(string memory _Art_name,
        string memory _owner_name,
        address _owner,
        bytes32 _hash,
        uint _ArtType,
        string memory _URL
        ) {
        Art_name = _Art_name;
        owner_name = _owner_name;
        owner = _owner;
        hash = _hash;
        ArtType = _ArtType;
        URL = _URL;
        registeredOn = block.timestamp;
    }
    
    modifier onlyOwner() {
        require (msg.sender == owner, "You are not the owner");
        _;
    }
    
    function checkOwner(address _owner) public{
        require(_owner == owner, "You are not the owner");
        emit verifyOwner("Verified");
    }
    function checkArtwork(string memory _art) public{
        require (keccak256(abi.encode(_art)) == hash, "This contract is not for above mentioned art");
        emit verifyArt("Verified");
    }
    
    function transferOwnership(address _owner) public onlyOwner {
        owner = _owner;
        emit transferOwner(msg.sender, owner);
    }
    
    function getartwork() public {
        emit GetArtwork(
            Art_name,
            owner_name,
            owner,
            hash,
            ArtType,
            URL,
            registeredOn
        );
    }
    
    function setPrice(uint _amt) public onlyOwner{
        price = _amt*(1 ether);
    }
    
    function setSell() public onlyOwner {
        sell = !sell;
    }
    
    function biSell() public payable{
        require(sell, "Item not on sell");
        require(msg.value >= price, "Not available for this price");
        prev_Owner = owner;
        owner = msg.sender;
        sell = false;
        payable(prev_Owner).transfer(msg.value);
    }
}