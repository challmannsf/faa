trigger FAAProcessStop on FAAProcessStop__e (after insert) {
    //once fraud check replied then set status on OS
    Map <String, Map<String, FAAProcessStop__e>> fraudProviderMap = new Map <String, Map<String, FAAProcessStop__e>>();
    for (FAAProcessStop__e processStopEvent : Trigger.new) {
        if(!fraudProviderMap.containsKey(processStopEvent.orderSummaryId__c)){
            fraudProviderMap.put(processStopEvent.orderSummaryId__c, new Map<String, FAAProcessStop__e>());
        }
        fraudProviderMap.get(processStopEvent.orderSummaryId__c).put(processStopEvent.fraudProvider__c, processStopEvent);
    }

    List<String> statusList = new List<String>{FAATriggerHelper.STATUS_APPROVED, FAATriggerHelper.STATUS_PENDING, FAATriggerHelper.STATUS_REJECTED, FAATriggerHelper.STATUS_MANUAL_REVIEW, FAATriggerHelper.STATUS_INITIATED};
    List<FAACheckLog__c> faaCheckLogs = [SELECT status__c, orderSummaryId__c, FraudProvider__c 
                                            FROM FAACheckLog__c
                                            WHERE orderSummaryId__c
                                            IN :fraudProviderMap.keySet() 
                                            AND status__c IN :statusList];

    List<FAACheckLog__c> faaCheckLogsToUpdate = new List<FAACheckLog__c>();
    for (FAACheckLog__c faaCheckLog : faaCheckLogs) {
        if (fraudProviderMap.get(faaCheckLog.OrderSummaryId__c).containsKey(faaCheckLog.fraudProvider__c)) {
            FAAProcessStop__e stopEvent = fraudProviderMap.get(faaCheckLog.OrderSummaryId__c).get(faaCheckLog.fraudProvider__c);
            faaCheckLog.status__c = stopEvent.fraudStatus__c;
            faaCheckLog.PendingSince__c = (faaCheckLog.status__c == FAATriggerHelper.STATUS_PENDING) ? datetime.now() : null;
            faaCheckLog.reason__c = stopEvent.reason__c;
            faaCheckLogsToUpdate.add(faaCheckLog);
        } 
    }
    update faaCheckLogsToUpdate;

    List<FAACheckLog__c> faaCheckLogsAfterUpdate = [SELECT status__c, orderSummaryId__c 
                                                        FROM FAACheckLog__c
                                                        WHERE orderSummaryId__c
                                                        IN :fraudProviderMap.keySet()];

    Map<Id, String> orderSummariesToCancelMap = new Map<Id, String>();   
    Map<Id, String> orderSummariesToManuallyReviewMap = new Map<Id, String>();
    Map<Id, String> orderSummariesToApproveMap = new Map<Id, String>();
    Map<Id, String> orderSummariesToPendingMap = new Map<Id, String>();
    Map<Id, String> orderSummariesToInitMap = new Map<Id, String>();
    
    for (FAACheckLog__c faaCheckLogAfterUpdate : faaCheckLogsAfterUpdate) {
        if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_REJECTED) {
            orderSummariesToCancelMap.put(faaCheckLogAfterUpdate.orderSummaryId__c, faaCheckLogAfterUpdate.status__c);
        } else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_MANUAL_REVIEW) {
            orderSummariesToManuallyReviewMap.put(faaCheckLogAfterUpdate.orderSummaryId__c,  faaCheckLogAfterUpdate.status__c);   
        }else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_PENDING) {
            orderSummariesToPendingMap.put(faaCheckLogAfterUpdate.orderSummaryId__c, faaCheckLogAfterUpdate.status__c);
        }else if (faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_INITIATED){
            orderSummariesToInitMap.put(faaCheckLogAfterUpdate.orderSummaryId__c, faaCheckLogAfterUpdate.status__c);
        }else if(faaCheckLogAfterUpdate.status__c == FAATriggerHelper.STATUS_APPROVED){
            orderSummariesToApproveMap.put(faaCheckLogAfterUpdate.orderSummaryId__c,  faaCheckLogAfterUpdate.status__c);
        }
    } 
                
    List<FAAProcessResult__e> faaProcessResultList = new List<FAAProcessResult__e>();
    FAAProcessResult__e faaProcessResult;
    
    // add cancel events 
    for (Id orderSummaryId : orderSummariesToCancelMap.keySet()) {
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = FAATriggerHelper.STATUS_REJECTED);
        faaProcessResultList.add(faaProcessResult);
    }
    
    // add manual review events 
    for (Id orderSummaryId : orderSummariesToManuallyReviewMap.keySet()) {
        if(!orderSummariesToCancelMap.containsKey(orderSummaryId)){
            faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = FAATriggerHelper.STATUS_MANUAL_REVIEW);
            faaProcessResultList.add(faaProcessResult);
        }   
    }
    
    // add pending events 
    for (Id orderSummaryId : orderSummariesToPendingMap.keySet()) {
        if(!orderSummariesToCancelMap.containsKey(orderSummaryId)
            && !orderSummariesToManuallyReviewMap.containsKey(orderSummaryId)){
        faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = FAATriggerHelper.STATUS_PENDING);
        faaProcessResultList.add(faaProcessResult);        
        }    
    }
    
    // add approved events 
    for (Id orderSummaryId : orderSummariesToApproveMap.keySet()) {
        if(!orderSummariesToCancelMap.containsKey(orderSummaryId) 
            && !orderSummariesToManuallyReviewMap.containsKey(orderSummaryId)
            && !orderSummariesToPendingMap.containsKey(orderSummaryId)
            && !orderSummariesToInitMap.containsKey(orderSummaryId)){
            faaProcessResult = new FAAProcessResult__e(orderSummaryId__c = orderSummaryId, result__c = FAATriggerHelper.STATUS_APPROVED);
            faaProcessResultList.add(faaProcessResult);
        }  
    }

    Logger.error(JSON.serialize(faaProcessResultList));
    Logger.saveLog();
    EventBus.publish(faaProcessResultList);
}