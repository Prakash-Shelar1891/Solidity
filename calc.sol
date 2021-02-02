pragma solidity ^0.8.0;

contract calc{
    uint public result = 0;
    
    function add(uint i, uint j) public{
        result = i + j;
    }
    
    function sub(uint i, uint j) public{
        result = i - j;
    }
    
    function mul(uint i, uint j) public{
        result = i * j;
    }
    
    function div(uint i, uint j) public{
        result = i / j;
    }
}