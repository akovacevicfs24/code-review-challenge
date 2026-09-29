trigger OpportunityRevenueTrigger on Opportunity (after insert, after update, after delete) {
    if (trigger.isUpdate) {
        OpportunityHelper.updateAccountRevenue(Trigger.new);
    }
    if (trigger.isDelete) {
        OpportunityHelper.updateAccountRevenue(Trigger.old);
    }
}