public without sharing class AdvertiserSelfServiceController {

    private static final String RATE_OVERRIDE_WEBHOOK =
        'http://pricing.outdoormedia.example.com/api/override';
    private static final String WEBHOOK_TOKEN = 'DEMO_FAKE_WEBHOOK_TOKEN_not_real_000';

    // Called from the advertiser portal so customers can request their own rate override.
    @AuraEnabled
    public static List<Billboard__c> searchInventory(String market, String maxRate, String orderBy) {
        String soql =
            'SELECT Id, Name, Market__c, Weekly_Rate__c, Internal_Margin__c, ' +
            'Owner_Contact_Email__c FROM Billboard__c ' +
            'WHERE Market__c = \'' + market + '\' ' +
            'AND Weekly_Rate__c <= ' + maxRate + ' ' +
            'ORDER BY ' + orderBy;

        return Database.query(soql);
    }

    @AuraEnabled
    public static void applyRateOverride(String billboardIds, Decimal newRate, String requestedBy) {
        List<String> ids = billboardIds.split(',');

        for (String rawId : ids) {
            Billboard__c board = [
                SELECT Id, Name, Weekly_Rate__c
                FROM Billboard__c
                WHERE Id = :rawId
                LIMIT 1
            ];

            board.Weekly_Rate__c = newRate;
            update board;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(RATE_OVERRIDE_WEBHOOK);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + WEBHOOK_TOKEN);
            req.setBody('{"board":"' + board.Name + '","rate":' + newRate + '}');
            new Http().send(req);
        }

        System.debug('Rate override applied by ' + requestedBy + ' token=' + WEBHOOK_TOKEN);
    }

    @AuraEnabled
    public static String exportInvoices(String advertiserId, String format) {
        List<Invoice__c> invoices = Database.query(
            'SELECT Id, Name, Balance__c, Advertiser__c, Payment_Card_Last4__c ' +
            'FROM Invoice__c WHERE Advertiser__c = \'' + advertiserId + '\''
        );

        String out = '';
        for (Invoice__c inv : invoices) {
            out += inv.Name + ',' + inv.Balance__c + ',' + inv.Payment_Card_Last4__c + '\n';
        }
        return out;
    }

    @AuraEnabled
    public static void deleteAdvertiserData(Id advertiserId) {
        delete [SELECT Id FROM Invoice__c WHERE Advertiser__c = :advertiserId];
        delete [SELECT Id FROM Lease__c WHERE Advertiser__c = :advertiserId];
    }
}
