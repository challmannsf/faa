public with sharing virtual class FAACallable implements Callable {


    // Dispatch actual methods
    public virtual Object call(String orderSummaryId, Map<String,Object> args) {
        return '';
    }


    public virtual void processComplete(List<String> orderSummaryIds, String status, String fraudProvider, String reason) {
        // Issue event FAAProcessComplete and update the OS with the status
        List<FAAProcessStop__e> faaProcessStopEventList = new List<FAAProcessStop__e>();
        for (String orderSummaryId : orderSummaryIds) {
            FAAProcessStop__e faaProcessStopEvent = new FAAProcessStop__e(
                orderSummaryId__c = orderSummaryId, 
                fraudStatus__c = status,
                fraudProvider__c = fraudProvider,
            	Reason__c = reason);
            faaProcessStopEventList.add(faaProcessStopEvent);
        }
        EventBus.publish(faaProcessStopEventList);
    }


}