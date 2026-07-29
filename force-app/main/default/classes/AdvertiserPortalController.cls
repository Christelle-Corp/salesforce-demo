public without sharing class AdvertiserPortalController {

    public String searchTerm { get; set; }
    public String returnUrl { get; set; }

    public PageReference redirectAfterLogin() {
        // returnUrl comes straight from the query string
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
    }

    public String getWelcomeBanner() {
        String advertiserName = ApexPages.currentPage().getParameters().get('advertiser');
        return '<div class="banner">Welcome back, ' + advertiserName + '</div>';
    }

    @AuraEnabled
    public static List<Invoice__c> getInvoices(String advertiserId) {
        return Database.query(
            'SELECT Id, Name, Balance__c, Due_Date__c FROM Invoice__c ' +
            'WHERE Advertiser__c = \'' + advertiserId + '\''
        );
    }

    @AuraEnabled
    public static void deleteInvoice(Id invoiceId) {
        Invoice__c inv = [SELECT Id FROM Invoice__c WHERE Id = :invoiceId];
        delete inv;
    }

    @AuraEnabled
    public static String impersonationToken(String userId) {
        String raw = userId + ':' + System.now().getTime();
        return EncodingUtil.base64Encode(Blob.valueOf(raw));
    }
}
