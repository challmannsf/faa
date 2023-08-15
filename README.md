# Fraud and Approval Manager

The Fraud and Approval Manager allows you to run Fraud and Approval checks for different providers in your Salesforce Order Management application. It orchestrates different providers and performs checks to get the Order Summary finally approved.
Every Fraud Status can be reviewed and monitored across the application, getting insights about your order lifecycle.

## Technical Documentation

### Register a Fraud Provider

All Fraud implementations must be written as an Apex class.
To register a class, it must extend the `FAACallable` Base Class.
Once a Fraud check is performed, `processComplete` must be invoked, ensuring to get the Order Summary approved
The following illustrates an example

```
public with sharing class ExampleFraudProvider extends FAACallable {
     // Dispatch actual methods
     public override Object call(String orderSummaryId) {
        this.processComplete(<orderSummaryId>, <status>);
     }
}
```
### Status

Only status which are available in `FAACheckLog__c.Status__c` are supported
