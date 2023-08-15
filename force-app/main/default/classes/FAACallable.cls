public with sharing virtual class FAACallable implements Callable {


    // Dispatch actual methods
    public virtual Object call(String orderSummaryId, Map<String,Object> args) {
    
        return '';
    }


    public virtual void processComplete(String orderSummaryId, String status) {
        // Issue event FAAProcessComplete and update the OS with the status

        List<FAAProcessStop__e> FAAProcessStopEventList = new List<FAAProcessStop__e>();
        FAAProcessStop__e FAAProcessStopEvent = new FAAProcessStop__e(orderSummaryId__c = orderSummaryId, fraudStatus__C = status);
        FAAProcessStopEventList.add(FAAProcessStopEvent);
        List<Database.SaveResult> results = EventBus.publish(FAAProcessStopEventList);
    }


}