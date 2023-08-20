public with sharing class ExampleFraudProviderManualReview extends FAACallable {
     // Dispatch actual methods
     public override Object call(String orderSummaryId, Map<String, Object> args) {
        this.processComplete(orderSummaryId, 'Manual Review', 'ExampleFraudProviderManualReview');
        return '';
     }
}