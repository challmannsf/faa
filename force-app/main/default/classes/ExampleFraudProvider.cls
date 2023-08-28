public with sharing class ExampleFraudProvider extends FAACallable {
     // Dispatch actual methods
     public override Object call(String orderSummaryId, Map<String, Object> args) {
         /**
          * Perform Fraud Check logic within that method and call this.processComplete now are after a call in
          */
        this.processComplete(orderSummaryId, 'Approved', 'ExampleFraudProvider');
        return '';
     }
}