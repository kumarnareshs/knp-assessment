/**
 * Created by naresh on 16/08/2021.
 */

@IsTest
private class OrderProductsControllerTest {

    @TestSetup
    private static void createTestData() {
        System.runAs(TestDataFactory.getAdminUser()) {
            TestDataFactory.createTestData();
        }
    }

    @IsTest
    private static void testGetOrderData() {
        //given
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        List<PricebookEntry> pricebookEntryList = [Select id from PricebookEntry];
        List<order> orderList = [Select id from order];
        AvailableProductsController.addOrderItem(pricebookEntryList[0].id, orderList[0].id);
        OrderProductsController.OrderData data = OrderProductsController.getOrderData(order.Id, 'ID', 'ASC');
        Test.stopTest();
        //expected
        System.assertEquals(false, data.isOrderActivated, 'Status of Order should be draft');
        System.assertEquals(1, data.orderItems.size(), 'One product should be in OrderItem');
    }

    @IsTest
    private static void testActivateOrderItemsSuccess() {
        //given
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        OrderHttpMock.successResponse = true;
        Test.setMock(HttpCalloutMock.class, new OrderHttpMock());

        OrderProductsController.activateOrderItems(order.Id);
        Test.stopTest();
        //expected Order will be Activated
        order = [SELECT Id,status FROM Order LIMIT 1];
        System.assertEquals('Activated', order.Status, 'Order should be Activated');

    }
}