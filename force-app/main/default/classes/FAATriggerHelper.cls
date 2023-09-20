public with sharing class FAATriggerHelper {
    public static final string STATUS_APPROVED = 'Approved';
    public static final string STATUS_PENDING = 'Pending';
    public static final string STATUS_REJECTED = 'Rejected';
    public static final string STATUS_MANUAL_REVIEW = 'Manual Review';
    public static final string STATUS_INITIATED = 'Initiated';

    /**
     * Provides the Order Summaries which have no pending check left
     */
    public static List<OrderSummary> getOrderSummariesToValidate(List <Id> orderSummaryIds) {

        List<FAACheckLog__c> pendingChecks = [SELECT ID, orderSummaryId__c, status__c, fraudProvider__c 
                                         FROM FAACheckLog__c 
                                         WHERE orderSummaryId__c 
                                         IN :orderSummaryIds
                                         AND status__c = :STATUS_PENDING];

        // Exclude pending checks
        for (FAACheckLog__c pendingCheck : pendingChecks) {
            if (orderSummaryIds.contains(pendingCheck.orderSummaryId__c)) {
                Integer index = orderSummaryIds.indexOf(pendingCheck.orderSummaryId__c);
                orderSummaryIds.remove(index);
            }
        }

        List<OrderSummary> orderSummaries = [SELECT ID, FAAFraudChecks__c 
                                            FROM OrderSummary 
                                            WHERE ID IN :orderSummaryIds];
        return orderSummaries;
    }

}