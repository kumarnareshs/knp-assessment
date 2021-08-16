/**
 * Created by naresh on 16/08/2021.
 */

@IsTest
private class AvailableProductsControllerTest {
    @TestSetup
    private static void createTestData() {
        System.runAs(TestDataFactory.getAdminUser()) {
            TestDataFactory.createTestData();
        }
    }

    @IsTest
    private static void TestGetAvailableProductsMethod() {
        Test.startTest();
        List<PricebookEntry> pricebookEntries = AvailableProductsController.getAvailableProducts('Id', 'Asc', null);
        Test.stopTest();
        System.assertEquals(2, pricebookEntries.size(), 'There should be 2 PricebookEntries');
    }

    @IsTest
    private static void TestUpdateOrderItemMethod() {

        List<PricebookEntry> pricebookEntryList = [Select id from PricebookEntry];
        List<order> orderList = [Select id from order];
        List<orderItem> orderItemList = [Select id,Quantity from orderItem];
        System.assertEquals(1, orderItemList[0].Quantity, 'There should be 1 orderItemList by testdata');
        Test.startTest();
        AvailableProductsController.addOrderItem(pricebookEntryList[0].id, orderList[0].id);
        Test.stopTest();
        orderItemList = [Select id,Quantity from orderItem];
        System.assertEquals(2, orderItemList[0].Quantity, 'orderItem is not added ');
    }
}