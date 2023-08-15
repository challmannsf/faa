trigger FAAProcessStop on FAAProcessStop__e (after insert) {
    Map <Id, String> orderAndStatusMap = new Map<Id, String>();
    for (FAAProcessStop__e processStopEvent : Trigger.New) {
        orderAndStatusMap.put(processStopEvent.orderSummaryId__c, processStopEvent.fraudStatus__c);
    }

    List<FAACheckLog__c> faaCheckLogs = [SELECT status__c, orderSummaryId__c 
                                            FROM FAACheckLog__c
                                            WHERE orderSummaryId__c
                                            IN :orderAndStatusMap.keySet()];

    List<FAACheckLog__c> faaCheckLogsToUpdate = new List<FAACheckLog__c>();
    for (FAACheckLog__c faaCheckLog : faaCheckLogs) {
        faaCheckLog.status__c = orderAndStatusMap.get(faaCheckLog.orderSummaryId__c);
        faaCheckLogsToUpdate.add(faaCheckLog);
    }
    insert faaCheckLogsToUpdate;

    List<FAACheckLog__c> faaCheckLogsAfterUpdate = [SELECT status__c, orderSummaryId__c 
                                            FROM FAACheckLog__c
                                            WHERE orderSummaryId__c
                                            IN :orderAndStatusMap.keySet()];

    Map<Id, String> orderSummariesToCancelMap = new Map<Id, String>();   
    Map<Id, String> orderSummariesToManuallyReviewMap = new Map<Id, String>();
    Map<Id, String> orderSummariesToApproveMap = new Map<Id, String>();
    
    for (FAACheckLog__c faaCheckLogAfterUpdate : faaCheckLogsAfterUpdate) {
        if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_REJECTED) {
            orderSummariesToCancelMap.put(faaCheckLogAfterUpdate.orderSummaryId__c, faaCheckLogAfterUpdate.status__c);
            
        } else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_MANUAL_REVIEW) {
            orderSummariesToManuallyReviewMap.put(faaCheckLogAfterUpdate.orderSummaryId__c,  faaCheckLogAfterUpdate.status__c);
        } else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_APPROVED) {
            // if it is approved, verify it has not been rejected or requires manual review from any preceding log entries
            Boolean orderNotCancelledOrManualReview = (orderSummariesToCancelMap.get(faaCheckLogAfterUpdate.orderSummaryId__c) == null || 
                                                      (orderSummariesToCancelMap.get(faaCheckLogAfterUpdate.orderSummaryId__c) != FAATriggerHelper.STATUS_REJECTED && 
                                                       orderSummariesToCancelMap.get(faaCheckLogAfterUpdate.orderSummaryId__c) != FAATriggerHelper.STATUS_MANUAL_REVIEW));
            if (orderNotCancelledOrManualReview) {
                orderSummariesToApproveMap.put(faaCheckLogAfterUpdate.orderSummaryId__c,  faaCheckLogAfterUpdate.status__c);
            }                
        }
    }

    List<FAAProcessResult__e> faaProcessResultList = new List<FAAProcessResult__e>();
    String recommendedOrderSummaryStatus;
    FAAProcessResult__e faaProcessResult;
    
    // add cancel events 
    for (Id orderSummaryId : orderSummariesToCancelMap.keySet()) {
        recommendedOrderSummaryStatus = orderSummariesToCancelMap.get(orderSummaryId);
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = recommendedOrderSummaryStatus);
        faaProcessResultList.add(faaProcessResult);
    }

    // add manual review events 
    for (Id orderSummaryId : orderSummariesToManuallyReviewMap.keySet()) {
        recommendedOrderSummaryStatus = orderSummariesToCancelMap.get(orderSummaryId);
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = recommendedOrderSummaryStatus);
        faaProcessResultList.add(faaProcessResult);
    }

    // add manual review events 
    for (Id orderSummaryId : orderSummariesToApproveMap.keySet()) {
        recommendedOrderSummaryStatus = orderSummariesToCancelMap.get(orderSummaryId);
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = recommendedOrderSummaryStatus);
        faaProcessResultList.add(faaProcessResult);
    }

    List<Database.SaveResult> results = EventBus.publish(faaProcessResultList);
}