public with sharing class ExampleFraudProviderManualReview extends FAACallable {
     // Dispatch actual methods
     public override Object call(String providerName, Map<String, Object> orderSummaryData) {
        this.processComplete((List<String>)orderSummaryData.get(providerName), 'Manual Review', providerName);
        return '';
     }
}