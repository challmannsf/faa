public with sharing class ExampleFraudProvider extends FAACallable {
     // Dispatch actual methods
     public override Object call(String orderSummaryId, Map<String, Object> args) {
        System.debug('ExampleFraudProvider is running');
        this.processComplete(orderSummaryId, 'Approved', 'ExampleFraudProvider');
        return '';
     }
}