import "job.sol";
import "punishment.sol";

contract Rewards
{   
    mapping (address => uint) balances;
    
    // list of jobs
    Job[] jobs;
    Punishment[] punishments;
    
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
            // TODO fix the compare of enum
            //if (jobs[i].state == Job.State.Proposed) {count++;}
            numProposedJobs++;
        }
        
        // allocate a static array in memory for the number of proposedJobs 
        proposedJobs = new Job[](numProposedJobs);
        uint proposedJobsIndex = 0;
        
        for (uint j = 0; j < numProposedJobs; j++)
        {
            proposedJobs[proposedJobsIndex++] = jobs[j];
        }
    }
    
    function addPunishment(address worker, string description, uint rewards) returns (Punishment punishment, uint newRewards)
    {
        punishment = new Punishment(punishments.length + 1, worker, description, rewards);
        punishments.push(punishment);
        
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
        //(success,  error) = job.start();
    }
    function endJob(uint id) {}
    function rejectJob(uint id) {}
    
    function() { throw; }
}