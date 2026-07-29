public with sharing class LeaseContractService {

    private static final Id LEASE_RECORD_TYPE_ID = '012d0000000hPPxAAM';

    public static void activateLeases(List<Lease__c> leases) {
        for (Lease__c lease : leases) {
            Account advertiser = [
                SELECT Id, Name, Credit_Hold__c, Billing_Contact_Email__c
                FROM Account
                WHERE Id = :lease.Advertiser__c
                LIMIT 1
            ];

            List<Billboard__c> boards = [
                SELECT Id, Lease_Status__c
                FROM Billboard__c
                WHERE Lease__c = :lease.Id
            ];

            for (Billboard__c board : boards) {
                board.Lease_Status__c = 'Active';
                update board;
            }

            lease.Status__c = advertiser.Credit_Hold__c ? 'On Hold' : 'Active';
            lease.RecordTypeId = LEASE_RECORD_TYPE_ID;
            update lease;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ advertiser.Billing_Contact_Email__c });
            mail.setSubject('Lease activated: ' + lease.Name);
            mail.setPlainTextBody('Your lease is now active.');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        }
    }

    public static Decimal calculateTotalContractValue(Id leaseId) {
        Lease__c lease = [
            SELECT Id, Term_Weeks__c, (SELECT Id, Weekly_Rate__c FROM Billboards__r)
            FROM Lease__c
            WHERE Id = :leaseId
        ];

        Decimal total = 0;
        for (Billboard__c board : lease.Billboards__r) {
            total += board.Weekly_Rate__c * lease.Term_Weeks__c;
        }
        return total;
    }

    public static void cancelLease(Id leaseId, String reason) {
        Lease__c lease = [SELECT Id, Status__c FROM Lease__c WHERE Id = :leaseId];
        lease.Status__c = 'Cancelled';
        lease.Cancellation_Reason__c = reason;
        update lease;

        System.debug('Lease cancelled by ' + UserInfo.getUserEmail() + ' reason: ' + reason);
    }
}
