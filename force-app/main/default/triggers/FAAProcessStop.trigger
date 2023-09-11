trigger FAAProcessStop on FAAProcessStop__e (after insert) {
    Map <String, String> fraudProviderStatusMap = new Map<String, String>();
    List <String> orderSummaryList = new List<String>();
    for (FAAProcessStop__e processStopEvent : Trigger.New) {
        fraudProviderStatusMap.put(processStopEvent.fraudProvider__c, processStopEvent.fraudStatus__c);
        orderSummaryList.add(processStopEvent.orderSummaryId__c);
    }

    List<FAACheckLog__c> faaCheckLogs = [SELECT status__c, orderSummaryId__c, FraudProvider__c 
                                            FROM FAACheckLog__c
                                            WHERE orderSummaryId__c
                                            IN :orderSummaryList];

    List<FAACheckLog__c> faaCheckLogsToUpdate = new List<FAACheckLog__c>();
    for (FAACheckLog__c faaCheckLog : faaCheckLogs) {
        if (fraudProviderStatusMap.get(faaCheckLog.fraudProvider__c) != null) {
            faaCheckLog.status__c = fraudProviderStatusMap.get(faaCheckLog.fraudProvider__c);
            faaCheckLog.PendingSince__c = (faaCheckLog.status__c == FAATriggerHelper.STATUS_PENDING) ? datetime.now() : null;
            faaCheckLogsToUpdate.add(faaCheckLog);
        } 
    
    }
    update faaCheckLogsToUpdate;

    List<FAACheckLog__c> faaCheckLogsAfterUpdate = [SELECT status__c, orderSummaryId__c 
                                            FROM FAACheckLog__c
                                            WHERE orderSummaryId__c
                                            IN :orderSummaryList];

    Map<Id, String> orderSummariesToCancelMap = new Map<Id, String>();   
    Map<Id, String> orderSummariesToManuallyReviewMap = new Map<Id, String>();
    Map<Id, String> orderSummariesToApproveMap = new Map<Id, String>();
    Map<Id, String> orderSummariesToPendingMap = new Map<Id, String>();
    
    for (FAACheckLog__c faaCheckLogAfterUpdate : faaCheckLogsAfterUpdate) {
        if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_REJECTED) {
            orderSummariesToCancelMap.put(faaCheckLogAfterUpdate.orderSummaryId__c, faaCheckLogAfterUpdate.status__c);
            
        } else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_MANUAL_REVIEW) {
            orderSummariesToManuallyReviewMap.put(faaCheckLogAfterUpdate.orderSummaryId__c,  faaCheckLogAfterUpdate.status__c);
            
        }else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_PENDING) {
            orderSummariesToPendingMap.put(faaCheckLogAfterUpdate.orderSummaryId__c, faaCheckLogAfterUpdate.status__c);
        }
        else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_APPROVED) {
            // if it is approved, verify it has not been rejected or requires manual review from any preceding log entries
            Boolean orderNotCancelledOrManualReview = (orderSummariesToCancelMap.get(faaCheckLogAfterUpdate.orderSummaryId__c) == null || 
                                                      (orderSummariesToCancelMap.get(faaCheckLogAfterUpdate.orderSummaryId__c) != FAATriggerHelper.STATUS_REJECTED && 
                                                      orderSummariesToManuallyReviewMap.get(faaCheckLogAfterUpdate.orderSummaryId__c) != FAATriggerHelper.STATUS_MANUAL_REVIEW &&
                                                      orderSummariesToPendingMap.get(faaCheckLogAfterUpdate.orderSummaryId__c) != FAATriggerHelper.STATUS_PENDING));
            if (orderNotCancelledOrManualReview) {
                orderSummariesToApproveMap.put(faaCheckLogAfterUpdate.orderSummaryId__c,  faaCheckLogAfterUpdate.status__c);
            }                
        } 
    }

    List<FAAProcessResult__e> faaProcessResultList = new List<FAAProcessResult__e>();
    FAAProcessResult__e faaProcessResult;
    
    // add cancel events 
    for (Id orderSummaryId : orderSummariesToCancelMap.keySet()) {
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = 'Rejected');
        faaProcessResultList.add(faaProcessResult);
    }

    // add manual review events 
    for (Id orderSummaryId : orderSummariesToManuallyReviewMap.keySet()) {
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = 'Manual Review');
        faaProcessResultList.add(faaProcessResult);
    }

    // add pending events 
    for (Id orderSummaryId : orderSummariesToPendingMap.keySet()) {
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = 'Pending');
        faaProcessResultList.add(faaProcessResult);
    }

    // add approved events 
    for (Id orderSummaryId : orderSummariesToApproveMap.keySet()) {
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = 'Approved');
        faaProcessResultList.add(faaProcessResult);
    }

    

    List<Database.SaveResult> results = EventBus.publish(faaProcessResultList);
}