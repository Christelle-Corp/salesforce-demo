@isTest
private class BillboardSearchControllerTest {

    @isTest
    static void testSearchBillboards() {
        Test.startTest();
        List<Billboard__c> results = BillboardSearchController.searchBillboards(
            'Baton Rouge',
            'North',
            'Name'
        );
        Test.stopTest();
        System.debug('Returned ' + results.size() + ' billboards');
    }

    @isTest
    static void testGetBillboardDetail() {
        Billboard__c board = new Billboard__c(Name = 'I-10 Mile 155', Market__c = 'Baton Rouge');
        insert board;

        Test.startTest();
        BillboardSearchController.getBillboardDetail(board.Id);
        Test.stopTest();
    }

    @isTest
    static void testFindByOwnerEmail() {
        BillboardSearchController.findByOwnerEmail('owner@example.com');
    }
}
