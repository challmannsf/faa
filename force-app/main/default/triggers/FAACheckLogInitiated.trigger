trigger FAACheckLogInitiated on FAACheckLog__c (after insert) {

    List<FAACheckLog__c> fraudCheckLogs = new List<FAACheckLog__c>();
    Map<String, List<String>> fraudCheckAndOrderSummaryMap = new Map<String, List<String>>();
    // Only run if initiated
    for (FAACheckLog__c fraudCheckLog : Trigger.New) {
        if (fraudCheckLog.status__c  != FAATriggerHelper.STATUS_INITIATED) {
            continue;
        }
        if (!fraudCheckAndOrderSummaryMap.containsKey(fraudCheckLog.FraudProvider__c)) {
            fraudCheckAndOrderSummaryMap.put(fraudCheckLog.FraudProvider__c, new List<String>());
        }
        fraudCheckAndOrderSummaryMap.get(fraudCheckLog.fraudProvider__c).add(fraudCheckLog.OrderSummaryId__c);
    }


    for (String fraudProvider : fraudCheckAndOrderSummaryMap.keySet()) {
        FAABase.invoke(fraudProvider, fraudCheckAndOrderSummaryMap.get(fraudProvider));
    }

 
}