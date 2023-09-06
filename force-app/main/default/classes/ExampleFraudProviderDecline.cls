public with sharing class ExampleFraudProviderDecline extends FAACallable {
     // Dispatch actual methods
     public override Object call(String providerName, Map<String, Object> orderSummaryData) {
        this.processComplete((List<String>)orderSummaryData.get(providerName), 'Rejected', providerName);
        return '';
     }
}