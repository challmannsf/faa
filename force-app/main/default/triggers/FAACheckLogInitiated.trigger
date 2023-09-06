trigger FAACheckLogInitiated on FAACheckLog__c (after insert) {

    List<FAACheckLog__c> fraudCheckLogs = new List<FAACheckLog__c>();
    Map<String, List<String>> fraudCheckAndOrderSummaryMap = new Map<String, List<String>>();
        // Only run if initiated
    for (FAACheckLog__c fraudCheckLog : Trigger.New) {
        if (fraudCheckLog.status__c  != 'Initiated') {
            continue;
        }
        List<String> orderSummariesToCheck = new List<String>();
        if (fraudCheckAndOrderSummaryMap.get(fraudCheckLog.FraudProvider__c) != null) {
            orderSummariesToCheck = fraudCheckAndOrderSummaryMap.get(fraudCheckLog.FraudProvider__c);
        }
        orderSummariesToCheck.add(fraudCheckLog.OrderSummaryId__c);
        fraudCheckAndOrderSummaryMap.put(fraudCheckLog.fraudProvider__c, orderSummariesToCheck);
    }


    for (String fraudProvider : fraudCheckAndOrderSummaryMap.keySet()) {
        FAABase.invoke(fraudProvider, fraudCheckAndOrderSummaryMap.get(fraudProvider));
    }

 
}