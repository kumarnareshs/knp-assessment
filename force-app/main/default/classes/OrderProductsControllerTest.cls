/**
 * Created by naresh on 16/08/2021.
 */

@IsTest
private class OrderProductsControllerTest {

    @TestSetup
    private static void createTestData(){
        System.runAs(TestDataFactory.getAdminUser()){
            TestDataFactory.createTestData();
        }
    }
    
}