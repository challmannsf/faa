/**
 * This event is pulished whenever the Fraud Check should be started
 * All Orders Fraud checks are executed which are residing in fraudChecks__c
 */

trigger FAAProcessStart on FAAProcessStart__e (after insert) {
    System.debug('FAAProcessStart called');
    List <Id> orderSummaryIds = new List<Id>();
    
    for (FAAProcessStart__e processStartEvent : Trigger.New) {
        orderSummaryIds.add(processStartEvent.OrderSummaryId__c);
        System.debug('FAAProcessStart called for Order Summary ' + processStartEvent.OrderSummaryId__c);
    }
    List<OrderSummary> orderSummaries = FAATriggerHelper.getOrderSummariesToValidate(orderSummaryIds);
    List<FAACheckLog__c> fraudCheckLogs = new List<FAACheckLog__c>();
    // Create a record, representing each fraud check and attach it to the order summary
    for (Ordersummary orderSummary : orderSummaries) {
        if (orderSummary.FAAFraudChecks__c != null) {
            List<String> requiredChecks = orderSummary.FAAFraudChecks__c.split(';');
            for (String checkToPerform : requiredChecks) {
                FAACheckLog__c fraudCheckLog = new FAACheckLog__c();
                fraudCheckLog.fraudProvider__c = checkToPerform;
                fraudCheckLog.status__c = FAATriggerHelper.STATUS_INITIATED;
                fraudCheckLog.orderSummaryId__c = orderSummary.ID;
                fraudCheckLogs.add(fraudCheckLog);
            }
        }
       
    }

    insert fraudCheckLogs;
}