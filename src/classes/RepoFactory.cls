public virtual class RepoFactory {
    public virtual IRepository getAccountRepo() {
        List<SObjectField> queryFields = new List<SObjectField>{
            Account.Name
        };
        return new Repository(Account.SObjectType, queryFields);
    }

    public virtual IRepository getOppRepo() {
        List<SObjectField> queryFields = new List<SObjectField>{
            Opportunity.IsWon,
            Opportunity.StageName
            //etc ...
        };
        return new Repository(Opportunity.SObjectType, queryFields);
    }

    public virtual IRepository getOppLineItemRepo() {
        List<SObjectField> queryFields = new List<SObjectField>{
            OpportunityLineItem.Description,
            OpportunityLineItem.OpportunityId
            //etc
        };
        return new Repository(OpportunityLineItem.SObjectType, queryFields);
    }

    //etc
}