pragma solidity ^0.8.0;

contract FIR {
    
    address police;
    
    struct Complaint {
        
        uint complaintID;
        address complaintBy;
        string complainant;
        address complaintAgainst;
        string complainee;
        string complaintAbout;
        uint complaintON;
        bool approved;
        uint approvedON;
        bool closed;
        uint closedON;
        bool cancel;
        uint cancelON;
        
    }
    // mapping(address=>Complaint[]) complaints;
    mapping(string=>address[]) tags;
    mapping(uint=>Complaint) complaints_by_Id;
    mapping(address=>uint[]) complaints_by_address;
    
    constructor() {
        police = msg.sender;
    }
    
    // Modifiers
    
    modifier complaintCheck(uint _complaintID) {
        require(complaints_by_Id[_complaintID].complaintID == _complaintID, "complaint is not exist.");
        _;
    }
    
    modifier checkPolice() {
        require(msg.sender != police, "Police cant file complaint.");
        _;
    }
    
    modifier onlyPolice() {
        require(msg.sender == police, "You are not police");
        _;
    }
    
    modifier onlyComplainant(uint _complaintID) {
        require(msg.sender == complaints_by_Id[_complaintID].complaintBy, "only Complainant can cancel the case");
        _;
    }
    
    //  Events
    
    event ComplainantFiled(uint complaintID, address complaintBy, string complainant, address complaintAgainst, string complainee, string complaintAbout, uint complaintON);
    
    event GetComplaint(uint complaintID, address complaintBy, string complainant, address complaintAgainst, string complainee, string complaintAbout, uint complaintON);
    
    event ComplainantStatus(uint complaintID, bool approved, uint approvedON, bool closed, uint closedON, bool cancel, uint cancelON);

    event ComplainantApproved(uint complaintID, bool approved, uint approvedON, address approvedBy);
    
    event ComplainantCancelled(uint complaintID, address complaintBy, bool cancel, uint cancelON);
    
    event ActionClosed(uint complaintID, bool closed, uint closedON, address complaintAgainst, uint value);
    
    
    uint counter;
    
    // Functions
    
    function makeComplaint(string memory _complainant, address _complaintAgainst, string memory _complainee, string memory _complaintAbout) public checkPolice(){
        counter++;
        Complaint memory complaint = Complaint(counter, msg.sender, _complainant, _complaintAgainst, _complainee, _complaintAbout, block.timestamp, false, 0, false, 0, false, 0);
        // complaints[msg.sender].push(complaint);
        complaints_by_Id[counter] = complaint;
        tags[_complaintAbout].push(_complaintAgainst);
        complaints_by_address[msg.sender].push(counter);
        
        emit ComplainantFiled(
            counter, 
            msg.sender, 
            _complainant, 
            _complaintAgainst, 
            _complainee, 
            _complaintAbout, 
            complaints_by_Id[counter].complaintON);
    }
    
    // Get all Complaint made by complainant address
    // function getAllComplaint(address _address) public view returns(Complaint[] memory){
    //     return complaints[_address];
    // }
    
    // Get single complaint by complaint ID
    function getComplaint(uint _complaintID) public returns(address complaintBy, string memory complainant, address complaintAgainst, string memory complainee, string memory complaintAbout, uint complaintON){
        require(complaints_by_Id[_complaintID].complaintID == _complaintID, "complaint is not exist.");
        
        emit GetComplaint(
            _complaintID, 
            complaints_by_Id[_complaintID].complaintBy, 
            complaints_by_Id[_complaintID].complainant, 
            complaints_by_Id[_complaintID].complaintAgainst, 
            complaints_by_Id[_complaintID].complainee, 
            complaints_by_Id[_complaintID].complaintAbout, 
            complaints_by_Id[_complaintID].complaintON);
        
        return(
            complaints_by_Id[_complaintID].complaintBy, 
            complaints_by_Id[_complaintID].complainant, 
            complaints_by_Id[_complaintID].complaintAgainst, 
            complaints_by_Id[_complaintID].complainee,  
            complaints_by_Id[_complaintID].complaintAbout,  
            complaints_by_Id[_complaintID].complaintON
        );
        
    }
    function getComplaintStatus(uint _complaintID) public returns(bool approved, uint approvedON, bool closed, uint closedON, bool cancel, uint cancelON) {
        require(complaints_by_Id[_complaintID].complaintID == _complaintID, "complaint is not exist.");
        
        emit ComplainantStatus(
            _complaintID,
            complaints_by_Id[_complaintID].approved, 
            complaints_by_Id[_complaintID].approvedON, 
            complaints_by_Id[_complaintID].closed,
            complaints_by_Id[_complaintID].closedON,
            complaints_by_Id[_complaintID].cancel,
            complaints_by_Id[_complaintID].cancelON);
        
        return(
            complaints_by_Id[_complaintID].approved, 
            complaints_by_Id[_complaintID].approvedON, 
            complaints_by_Id[_complaintID].closed,
            complaints_by_Id[_complaintID].closedON,
            complaints_by_Id[_complaintID].cancel,
            complaints_by_Id[_complaintID].cancelON);
    }
    
    // Get all complainee with tag 
    // all address will fetch which has perticular complaint against them 
    function getAllcomplaintByTag(string memory _tag) public view returns(address[] memory){
        return tags[_tag];
    }
    
    // Get all complaint ID which filed by address
    function getComplaintIDs(address _complainant) public view returns(uint[] memory) {
        return complaints_by_address[_complainant];
    }
    
    function approveCase(uint _complaintID) public onlyPolice() complaintCheck(_complaintID) {
        require(complaints_by_Id[_complaintID].cancel == false, "Complaint is canceled by complainant.");
        complaints_by_Id[_complaintID].approved = true;
        complaints_by_Id[_complaintID].approvedON = block.timestamp;
        
        emit ComplainantApproved(_complaintID, complaints_by_Id[_complaintID].approved, complaints_by_Id[_complaintID].approvedON, police);
    }
    
    function takeAction(uint _complaintID) public complaintCheck(_complaintID) payable{
        require(complaints_by_Id[_complaintID].approved == true, "Complaint is not approved yet.");
        require(complaints_by_Id[_complaintID].complaintAgainst == msg.sender, "You are not punished.");
        require(msg.value > 2 ether, "You need to pay more");
        
        payable(complaints_by_Id[_complaintID].complaintBy).transfer(msg.value);
        
        complaints_by_Id[_complaintID].closed = true;
        complaints_by_Id[_complaintID].closedON = block.timestamp;
        
        emit ActionClosed(_complaintID, complaints_by_Id[_complaintID].closed, complaints_by_Id[_complaintID].closedON, complaints_by_Id[_complaintID].complaintAgainst, msg.value);
        
    }
    
    function cancelCase(uint _complaintID) public complaintCheck(_complaintID) onlyComplainant(_complaintID) {
        require(complaints_by_Id[_complaintID].closed == false, "Complaint is already closed.");
        complaints_by_Id[_complaintID].cancel = true;
        complaints_by_Id[_complaintID].cancelON = block.timestamp;
        
        emit ComplainantCancelled(_complaintID, complaints_by_Id[_complaintID].complaintBy, complaints_by_Id[_complaintID].cancel, complaints_by_Id[_complaintID].cancelON);
    }
    
}