pragma solidity ^0.8.0;

contract Dwitter {
    address manager;    
    struct User {
        address userAddress;
        string userName;
        uint accountCreatedON;
        bool signIn;
        bool accountStatus;
        address[] followers;
        address[] following;
    }
    
    mapping(address=>User) public users;
    mapping(string=>address) userNameToAddress;
    
    event newUser(address userAddress, string userName, uint accountCreatedON, uint followers, uint following);
    event newTweet(uint postID, string userName, string content, string tag);
    
    event userSignIN(address userAddress, string userName, uint accountCreatedON, uint followers, uint following);
    
    
    struct Post {
        uint postId;
        string content;
        string tag;
    }
    
    uint postCount;
    mapping(address=>Post[]) posts;
    Post[] allPosts;
    mapping(uint=>Post) idToPost;
    mapping(uint=>address) idToUser;
    // mapping(uint => mapping(address => Post)) postIdToUser;
    mapping(string=>Post[]) tagsToPost;
    
    mapping(uint=>address[]) likes;
    mapping(uint=>address[]) reTweets;
    
    constructor() {
        manager = msg.sender;
    }
    
    // Modifiers
    
    modifier userExist(address _userAddress) {
        require(users[_userAddress].userAddress == _userAddress, "User is not Exist");
        _;
    }
    modifier checkUser(string memory _userName) {
        require(users[userNameToAddress[_userName]].accountStatus, "No user found");
        _;
    }
    
    modifier checkSignIn(address _userAddress) {
        require(users[_userAddress].signIn, "You are not signed In");
        _;
    }
    
    modifier checkSignOut(address _userAddress) {
        require(!users[_userAddress].signIn, "You are not signed out");
        _;
    }
    
    modifier checkAccountStatus(address _userAddress) {
        require(users[_userAddress].accountStatus, "This Account is deactivated");
        _;
    }
    
    // modifier checkFollowed(address _userAddress) {
    //     require(users[_userAddress].following == users[msg.sender].followers);
    //     _;
    // }
    
    // Functions
    
    function signUP(string memory _userName) public {
        require(msg.sender != manager, "manager must not be User");
        require(users[msg.sender].userAddress == address(0), "Account already Exists");
        // User memory user = User(msg.sender, _userName, block.timestamp, true, true, 0);
        // users[msg.sender] = user;
        userNameToAddress[_userName] = msg.sender;
        users[msg.sender].userAddress = msg.sender;
        users[msg.sender].userName = _userName;
        users[msg.sender].accountCreatedON = block.timestamp;
        users[msg.sender].signIn = true;
        users[msg.sender].accountStatus = true;
        
        emit newUser(msg.sender, _userName, users[msg.sender].accountCreatedON, 0, 0);
    }
    
    function searchUser(string memory _userName) public userExist(msg.sender) checkAccountStatus(msg.sender) checkSignIn(msg.sender) checkUser(_userName) view returns(string memory, uint, uint, uint, string memory) {
        require(users[userNameToAddress[_userName]].accountStatus == true, "This Accout is deactivated");
        if(users[userNameToAddress[_userName]].signIn == true) {
            return(users[userNameToAddress[_userName]].userName, users[userNameToAddress[_userName]].followers.length, users[userNameToAddress[_userName]].following.length, users[userNameToAddress[_userName]].accountCreatedON, "Online");
        }else {
            return(users[userNameToAddress[_userName]].userName, users[userNameToAddress[_userName]].followers.length,users[userNameToAddress[_userName]].following.length, users[userNameToAddress[_userName]].accountCreatedON, "Offline");
        }
    }

    function getUserByAddress() public userExist(msg.sender) checkAccountStatus(msg.sender) checkSignIn(msg.sender) view returns(string memory, uint, uint, uint) {
        return(users[msg.sender].userName, users[msg.sender].followers.length, users[msg.sender].following.length, users[msg.sender].accountCreatedON);
    }
    
    
    
    function makeSignIn() public userExist(msg.sender) {
        // If person deactivated by themself then they can active their account by signIn again
        if(!users[msg.sender].accountStatus) {
            users[msg.sender].accountStatus = true;
        }
        else {
            users[msg.sender].signIn = true;
        }
        
        emit userSignIN(msg.sender, users[msg.sender].userName, users[msg.sender].accountCreatedON, users[msg.sender].followers.length, users[msg.sender].following.length);
    }
    function makeSignOut() public userExist(msg.sender) checkSignIn(msg.sender){
        users[msg.sender].signIn = false;
    }
    
    function accountDeactive() public checkAccountStatus(msg.sender) userExist(msg.sender) checkSignIn(msg.sender) {
        users[msg.sender].accountStatus = false;
    }
    
    function tweet(string memory _content, string memory _tag) public checkAccountStatus(msg.sender) userExist(msg.sender) checkSignIn(msg.sender) {
        postCount++;
        Post memory post = Post(postCount, _content, _tag);
        posts[msg.sender].push(post);
        tagsToPost[_tag].push(post);
        idToPost[postCount] = post;
        idToUser[postCount] = msg.sender;
        allPosts.push(post);
        
        emit newTweet(postCount, users[msg.sender].userName, _content, _tag);
    }
    
    function getTweetsOfUser(string memory _userName)public userExist(msg.sender) checkSignIn(msg.sender) checkAccountStatus(userNameToAddress[_userName]) view returns(Post[] memory) {
        return(posts[userNameToAddress[_userName]]);
    }
    
    function getUserByPostId(uint _postID)public userExist(msg.sender) checkSignIn(msg.sender) view returns(address){
        return idToUser[_postID];
    }
    
    function getAllPosts() public userExist(msg.sender) checkSignIn(msg.sender) view returns(Post[] memory) {
        return allPosts;
    }
    
    function getTagPost(string memory _tag) public checkAccountStatus(msg.sender) checkSignIn(msg.sender) view returns(Post[] memory) {
        return tagsToPost[_tag];
    }
    
    function followUser(string memory _userName) public userExist(msg.sender) checkSignIn(msg.sender) userExist(userNameToAddress[_userName]) checkAccountStatus(userNameToAddress[_userName]) {
        require(!alreadyFollowed(_userName), "You have already Followed");
        users[userNameToAddress[_userName]].followers.push(msg.sender);
        users[msg.sender].following.push(userNameToAddress[_userName]);
    }
    
    // function unfollow(string memory _userName)public userExist(msg.sender) checkSignIn(msg.sender) userExist(userNameToAddress[_userName]) checkAccountStatus(userNameToAddress[_userName]) {
    //     address[] memory FollowedAddress = users[userNameToAddress[_userName]].followers;
        
    //     for(uint i = 0; i<FollowedAddress.length; i++){
    //         if(msg.sender == FollowedAddress[i]){
    //             users[userNameToAddress[_userName]].followers.pop();
    //         }
    //     }
    // }
    
    function alreadyFollowed(string memory _userName) public view returns(bool){
        
        address[] memory FollowedAddress = users[userNameToAddress[_userName]].followers;
        
        for(uint i=0; i < FollowedAddress.length; i++){
            if(msg.sender == FollowedAddress[i]){
                return true;
            }
        }
    }
    
    function likePost(uint _postID) public checkAccountStatus(msg.sender) checkSignIn(msg.sender){
        require(!alreadyLiked(_postID), "You have already Liked");
        likes[_postID].push(msg.sender);
    }
    
    function alreadyLiked(uint _postID) public view returns(bool){
        address[] memory likedAddress = likes[_postID];
        
        for(uint i=0; i < likedAddress.length; i++){
            if(msg.sender == likedAddress[i]){
                return true;
            }
        }
    }
    
    function getLikesByPostID(uint _postID) public checkSignIn(msg.sender) view returns(address[] memory) {
        return likes[_postID];
    }
    
    function reTweet(uint _postID) public checkAccountStatus(msg.sender) checkSignIn(msg.sender){
        require(!alreadyRetweeted(_postID), "You have already Re-Twitted");
        reTweets[_postID].push(msg.sender);
    }
    
    function alreadyRetweeted(uint _postID) public view returns(bool){
        address[] memory RetweetedAddress = reTweets[_postID];
        
        for(uint i=0; i < RetweetedAddress.length; i++){
            if(msg.sender == RetweetedAddress[i]){
                return true;
            }
        }
    }
    
    function getReTweetByPostID(uint _postID) public checkSignIn(msg.sender) view returns(address[] memory) {
        return reTweets[_postID];
    }
}