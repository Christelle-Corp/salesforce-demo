@isTest
private class AdvertiserSelfServiceControllerTest {

    @isTest
    static void testSearchInventory() {
        AdvertiserSelfServiceController.searchInventory('Baton Rouge', '500', 'Name');
    }

    @isTest
    static void testExportInvoices() {
        AdvertiserSelfServiceController.exportInvoices('001000000000000', 'csv');
    }
}
