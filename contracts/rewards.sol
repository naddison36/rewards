import "Job.sol";
import "Penalty.sol";

contract Rewards
{   
    mapping (address => uint) balances;
    
    // list of jobs
    Job[] jobs;
    Penalty[] penalties;
    
    function proposeJob(string description, uint proposedReqards) returns (Job job)
    {
        job = new Job(jobs.length + 1, description, proposedReqards);
        jobs.push(job);
    }
    
    // TODO change to get jobs in a particular state
    // gets all the jobs in Proposed state
    function getProposedJobs() constant returns (Job[] proposedJobs)
    {
        // can only return statically sized arrays to external calls so need to
        // count the number of proposed jobs and then
        // create a statically sized array that can be returned to an external call
        uint numProposedJobs = 0;
        for (uint i = 0; i < jobs.length; i++)
        {
            if (jobs[i].state() == Job.State.Proposed) { numProposedJobs++; }
        }
        
        // allocate a static array in memory for the number of proposedJobs 
        proposedJobs = new Job[](numProposedJobs);
        uint proposedJobsIndex = 0;
        
        for (uint j = 0; j < numProposedJobs; j++)
        {
            proposedJobs[proposedJobsIndex++] = jobs[j];
        }
    }
    
    // creates a new penalty and reduces the rewards of the worker that is being penalised
    function addPenalty(address worker, string description, uint rewards) returns (Penalty penalty, uint newRewards)
    {
        penalty = new Penalty(penalties.length + 1, worker, description, rewards);
        penalties.push(penalty);
        
        newRewards = balances[worker] - rewards;
        
        if (newRewards < 0)
        {
            newRewards = 0;
        }
        
        balances[worker] = newRewards;
    }
    
    function approveJob(uint id) returns (bool success, string error, Job job)
    {
        // if job id is out of range of the listed jobs
        if (id < 0 || id >= jobs.length)
        {
            success = false;
            error = "Could not find job";
            return;
        }
        
        job = jobs[id];
        
        uint oldRemainingRewards = job.remainingRewards();
        
        // TODO add this back after fixing "Type bool is not implicitly convertible to expected type tuple(bool,string memory)."
        //(success, error) = job.approve();
        success = true;
        
        if (success)
        {
            balances[msg.sender] = balances[msg.sender] + oldRemainingRewards;
        }
    }
    
    function startJob(uint id) returns (bool success, string error, Job job)
    {
        // if job id is out of range of the listed jobs
        if (id < 0 || id >= jobs.length)
        {
            success = false;
            error = "Could not find job";
            return;
        }
        
        job = jobs[id];
        // TODO See ping.sol and pong.sol for example of Get return value from non-constant function from another contract
        //(success, error) = job.start();
    }
    
    function endJob(uint id) {}
    function rejectJob(uint id) {}
    
    event Transfer(address from, address to, uint rewards);
    
    // transfers rewards between workers
    function transfer(address from, address to, uint rewards) returns (bool success, string error)
    {
        // if from address does not exist
        if (balances[from] == 0)
        {
            return (false, "from address doesn't have any rewards");
        }
        else if (balances[from] < rewards)
        {
            return (false, "not enough rewards to transfer");
        }
        else if (rewards <= 0)
        {
            return (false, "can not transfer a negative amount");
        }
        
        balances[to] += rewards;
        balances[from] -= rewards;
        
        Transfer(from, to, rewards);
    }
    
    // return Ether if someone sends Ether to this contract
    function() { throw; }
}