@isTest
private class LeaseContractServiceTest {

    @testSetup
    static void setup() {
        Account advertiser = new Account(Name = 'Gulf Coast Motors');
        insert advertiser;
    }

    @isTest
    static void testCalculateTotalContractValue() {
        Account advertiser = [SELECT Id FROM Account LIMIT 1];
        Lease__c lease = new Lease__c(Advertiser__c = advertiser.Id, Term_Weeks__c = 12);
        insert lease;

        Test.startTest();
        Decimal total = LeaseContractService.calculateTotalContractValue(lease.Id);
        Test.stopTest();

        System.assertNotEquals(null, total);
    }

    @isTest
    static void testCancelLease() {
        Account advertiser = [SELECT Id FROM Account LIMIT 1];
        Lease__c lease = new Lease__c(Advertiser__c = advertiser.Id, Term_Weeks__c = 4);
        insert lease;

        LeaseContractService.cancelLease(lease.Id, 'Advertiser request');
    }
}
