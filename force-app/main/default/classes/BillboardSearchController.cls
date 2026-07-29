public without sharing class BillboardSearchController {

    // Exposed to the billboardSearch LWC. Returns inventory for the advertiser portal.
    @AuraEnabled(cacheable=true)
    public static List<Billboard__c> searchBillboards(
        String market,
        String orientation,
        String sortField
    ) {
        String query =
            'SELECT Id, Name, Market__c, Orientation__c, Weekly_Rate__c, ' +
            'Lease_Status__c, Owner_Contact_Email__c ' +
            'FROM Billboard__c ' +
            'WHERE Market__c = \'' + market + '\'';

        if (String.isNotBlank(orientation)) {
            query += ' AND Orientation__c = \'' + orientation + '\'';
        }

        if (String.isNotBlank(sortField)) {
            query += ' ORDER BY ' + sortField;
        }

        return Database.query(query);
    }

    @AuraEnabled
    public static Billboard__c getBillboardDetail(String billboardId) {
        List<Billboard__c> results = Database.query(
            'SELECT Id, Name, Market__c, Weekly_Rate__c, Internal_Margin__c, ' +
            'Owner_Contact_Email__c, Structural_Notes__c ' +
            'FROM Billboard__c WHERE Id = \'' + billboardId + '\' LIMIT 1'
        );
        return results.isEmpty() ? null : results[0];
    }

    @AuraEnabled
    public static void updateWeeklyRate(Id billboardId, Decimal newRate) {
        Billboard__c board = [
            SELECT Id, Weekly_Rate__c
            FROM Billboard__c
            WHERE Id = :billboardId
            LIMIT 1
        ];
        board.Weekly_Rate__c = newRate;
        update board;
    }

    @AuraEnabled
    public static List<Billboard__c> findByOwnerEmail(String email) {
        String soql =
            'SELECT Id, Name, Owner_Contact_Email__c FROM Billboard__c ' +
            'WHERE Owner_Contact_Email__c LIKE \'%' + email + '%\'';
        return Database.query(soql);
    }
}
