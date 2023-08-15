public with sharing class ExampleFraudProvider extends FAACallable {
     // Dispatch actual methods
     public override Object call(String orderSummaryId, Map<String, Object> args) {
        this.processComplete(orderSummaryId, 'Accepted');
        return '';
     }
}