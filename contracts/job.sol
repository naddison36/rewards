contract Job
{
    // unique identifier for this job
    uint id;
    
    address public superviser;
    address public worker;
    
    string public description;
    
    enum State {Proposed, Working, Review, Approved, Rejected}
    
    State public state;
    
    uint proposedRewards;
    uint earnedRewards;
    
    function Job(uint _id, string _description, uint _proposedReqards)
    {
        id = _id;
        description = _description;
        proposedRewards = _proposedReqards;
        
        // TODO is this sender or origin?
        superviser = msg.sender;
        state = State.Proposed;
    }
    
    function remainingRewards() constant returns (uint rewards)
    {
        return proposedRewards - earnedRewards;
    }
    
    function start() returns (bool success, string error)
    {
        worker = msg.sender;
        
        if (state == State.Working || state == State.Approved)
        {
            return (false, "job can not be started when it's in Working or Approved state");
        }
        
        state = State.Working;
        //success = true;
        
        return (true, "success");
        //return ("success", "2");
    }
    
    function end() returns (bool success, string error)
    {
        // only the worker that started the work can end the job
        if (worker != msg.sender)
        {
            return (false, "only the worker who started the job can end the job so it's ready for review");
        }
        
        if (state == State.Approved)
        {
            return (false, "can not complete a job that has already been approved by the superviser");
        }
        
        // if jumping straight from Proposed to Review
        if (state == State.Proposed)
        {
            // transition through Working first
            start();
        }
        
        state = State.Review;
        success = true;
    }
    
    function approve() returns (bool success, string error)
    {
        if (superviser != msg.sender)
        {
            return (false, "only the superviser can approve a job");
        }
        
        if (state == State.Proposed)
        {
            return (false, "can not approve a job that a worker has not started");
        }
        
        earnedRewards = proposedRewards;
        
        state = State.Approved;
        success = true;
    }
    
    function reject() returns (bool success, string error)
    {
        if (superviser != msg.sender)
        {
            return (false, "only the superviser can reject a job");
        }
        
        state = State.Rejected;
        success = true;
    }
    
    // return Ether if someone sends Ether to this contract
    function() { throw; }
}