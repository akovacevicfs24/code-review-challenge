@isTest(SeeAllData=true)
private class OpportunityTriggerTest {

    @isTest
    static void testTrigger() {
        Account a = [SELECT Id FROM Account LIMIT 1];

        Opportunity opp = new Opportunity(
            Name = 'Trigger Test',
            AccountId = a.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 5000
        );
        insert opp;

        Opportunity result = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Closed Won', result.StageName);
    }
}