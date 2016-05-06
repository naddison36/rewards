contract Punishment
{
    // unique identifier for this job
    uint id;
    
    address public superviser;
    address public worker;
    
    string public description;
    uint rewards;
    
    function Punishment(uint _id, address _worker, string _description, uint _rewards)
    {
        id = _id;
        description = _description;
        rewards = _rewards;
        
        superviser = msg.sender;
        worker = _worker;
    }
    
    // return Ether if someone sends Ether to this contract
    function() { throw; }
}