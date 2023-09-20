public with sharing class ExampleFraudProvider extends FAACallable {
     // Dispatch actual methods
     public override Object call(String providerName, Map<String, Object> orderSummaryData) {
         /**
          * Perform Fraud Check logic within that method and call this.processComplete now are after a call in
          */
        this.processComplete((List<String>)orderSummaryData.get(providerName), 'Approved', providerName, 'Some Reason');
        return '';
     }
}