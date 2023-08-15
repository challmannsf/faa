/**
 * This event is pulished whenever the Fraud Check should be started
 * All Orders Fraud checks are executed which are residing in fraudChecks__c
 */

// If no specific flag is found, execute all found Fraud checks
// Fraud check executes and triggers a finish event
// FAAProcessHandler gathers fraud check results and than accept or rejects the order summary
    // Handle also pending checks (this requires to keep track of what was aleady passed) 
trigger FAAProcessStart on FAAProcessStart__e (after insert) {
    List <Id> orderSummaryIds = new List<Id>();
    for (FAAProcessStart__e processStartEvent : Trigger.New) {
        orderSummaryIds.add(processStartEvent.OrderSummaryId__c);
    }
    List<OrderSummary> orderSummaries = FAATriggerHelper.getOrderSummariesToValidate(orderSummaryIds);
    List<FAACheckLog__c> fraudCheckLogs = new List<FAACheckLog__c>();
    // Create a record, representing each fraud check and attach it to the order summary
    for (Ordersummary orderSummary : orderSummaries) {
        List<String> requiredChecks = orderSummary.fraudChecks__c.split(';');
        for (String checkToPerform : requiredChecks) {
            FAACheckLog__c fraudCheckLog = new FAACheckLog__c();
            fraudCheckLog.fraudProvider__c = checkToPerform;
            fraudCheckLog.status__c = FAATriggerHelper.STATUS_INITIATED;
            fraudCheckLog.orderSummaryId__c = orderSummary.ID;
            fraudCheckLogs.add(fraudCheckLog);
        }
    }

    insert fraudCheckLogs;
}