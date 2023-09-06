public with sharing class FAABase {

    public static void invoke(String fraudCheckProvider, List<String> orderSummaryIds) {

        try {
            Map<String, Object> orderSummaryData = new Map<String, Object>();
            orderSummaryData.put(fraudCheckProvider, orderSummaryIds);

            Callable extension = 
            (Callable) Type.forName(fraudCheckProvider).newInstance();
            extension.call(fraudCheckProvider, orderSummaryData);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
      

    }
}