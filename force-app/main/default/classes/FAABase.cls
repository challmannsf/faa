public with sharing class FAABase {

    public static void invoke(String fraudCheckProvider, Id orderSummaryId) {

        try {
            Callable extension = 
            (Callable) Type.forName(fraudCheckProvider).newInstance();
            extension.call(orderSummaryId, new Map<String, Object> {});
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
      

    }
}