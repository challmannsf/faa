trigger FAACheckLogInitiated on FAACheckLog__c (after insert) {

    List<FAACheckLog__c> fraudCheckLogs = new List<FAACheckLog__c>();
    for (FAACheckLog__c fraudCheckLog : Trigger.New) {
        // Only run if initiated
        if(fraudCheckLog.status__c == 'Initiated') {
            FAABase.invoke(fraudCheckLog.fraudProvider__c, fraudCheckLog.orderSummaryId__c);
        }
    }
}