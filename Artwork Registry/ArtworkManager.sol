pragma solidity ^0.8.0;

import "./ArtworkInterface.sol";

contract ArtworkManager {
    mapping(address => ArtworkInterface[])userArt;
    mapping(bytes32 => address)artOwner;
    
    event ArtRegistration(address, string);
    event ArtRegistered(address _artAdrs, address _owner, string _art);
    
    modifier checkIfRegistered(string memory _art) {
        require (artOwner[keccak256(abi.encode(_art))] == address(0), "Already Registered");
        _;
    }
    
    function registerArtwork(string memory _art ,string memory _artUrl, string memory _owner_name, uint _ArtType) public checkIfRegistered(_artUrl) {
        emit ArtRegistration(msg.sender, _artUrl);
        bytes32 hash = keccak256(abi.encode(_artUrl));
        ArtworkInterface art = new ArtworkInterface(
            _art,
            _owner_name,
            msg.sender,
            hash,
            _ArtType,
            _artUrl
            );
        userArt[msg.sender].push(art);
        artOwner[hash] = msg.sender;
        emit ArtRegistered(address(art), msg.sender, _art);
    }
    
    function getArtByOwner(address _owner) public view returns(ArtworkInterface[] memory){
        return userArt[_owner];
    }
    
    function getOwnerByArt(string memory _art) public view returns(address _owner){
        return artOwner[keccak256(abi.encode(_art))];
    }
    
    function isRegistered(string memory _art) public view checkIfRegistered(_art){}
    
}
