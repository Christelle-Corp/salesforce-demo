public class LeaseRenewalBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Integer processed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Advertiser__c, Status__c, End_Date__c FROM Lease__c'
        );
    }

    public void execute(Database.BatchableContext bc, List<Lease__c> scope) {
        for (Lease__c lease : scope) {
            Account advertiser = [
                SELECT Id, Auto_Renew__c, Billing_Contact_Email__c
                FROM Account
                WHERE Id = :lease.Advertiser__c
            ];

            if (advertiser.Auto_Renew__c) {
                lease.End_Date__c = lease.End_Date__c.addYears(1);
                lease.Status__c = 'Renewed';
                update lease;
                processed++;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Renewed ' + processed + ' leases');
    }
}
