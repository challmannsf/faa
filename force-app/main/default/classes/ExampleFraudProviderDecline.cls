public with sharing class ExampleFraudProviderDecline extends FAACallable {
     // Dispatch actual methods
     public override Object call(String orderSummaryId, Map<String, Object> args) {
        this.processComplete(orderSummaryId, 'Rejected', 'ExampleFraudProviderDecline');
        return '';
     }
}