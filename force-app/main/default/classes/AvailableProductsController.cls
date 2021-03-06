/**
 * Created by Naresh Kumar on 16/08/2021.
 */

public with sharing class AvailableProductsController {
    /**
     * Stores the Id of the Order Record
     */
    private static Id orderId;

    /**
     * Getter to get a list of Order Items
     */
    public static List<OrderItem> orderItems {
        get {
            if (orderItems == null) {
                orderItems = new List<OrderItem>();
                orderItems = [
                        SELECT Id, Product2.Name, Quantity, UnitPrice, TotalPrice, Product2Id
                        FROM OrderItem
                        WHERE OrderId = :orderId
                        WITH SECURITY_ENFORCED
                ];
            }
            return orderItems;
        }
        set {
        }
    }

    /**
     * Method to get available products
     * @param sortBy order by column name
     * @param sortDirection order by direction
     * @param search search by product name
     *
     * @return List of PricebookEntry
     */
    @AuraEnabled(Cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(String sortBy, String sortDirection, String search) {
        if (!String.isBlank(sortBy) && !String.isBlank(sortDirection)) {
            String defaultPricebookName = Label.Default_Pricebook_Name;
            List<Pricebook2> pricebookList = [
                    SELECT id
                    FROM Pricebook2
                    WHERE name = :defaultPricebookName
            ];
            if (pricebookList == null || pricebookList.size() == 0) {
                throw new customException(Label.Data_Error);
            }
            String query = 'SELECT Name,Id,UnitPrice,Product2Id,Pricebook2Id FROM PricebookEntry ' + 'WHERE IsActive = TRUE AND Pricebook2Id = \'' +
                    pricebookList[0].id + '\'';
            if (!String.isBlank(search)) {
                query += ' AND Name like \'%' + search + '%\'';
            }
            query += ' WITH SECURITY_ENFORCED ';
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;

            return Database.query(query);
        }
        throw new customException(Label.Invalid_Arguments);
    }

    /**
     * Method to add the order items
     * @param priceBookEntryId
     * @param orderRecordId
     * @return Boolean is the method successful
     */
    @AuraEnabled
    public static Boolean addOrderItem(Id priceBookEntryId, Id orderRecordId) {
        if (!String.isBlank(priceBookEntryId) && !String.isBlank(orderRecordId)) {
            try {
                List<Order> order = [Select id, status from order where id = :orderRecordId];
                if (order != null && order.size() == 1 & order[0].status == 'Activated') {
                    throw new CustomException(Label.Order_Activated_Error);
                }
                orderId = orderRecordId;
                List<PricebookEntry> pricebookEntry = [
                        SELECT Name, Id, UnitPrice, Product2Id, Pricebook2Id
                        FROM PricebookEntry
                        WHERE Id = :PricebookEntryId
                ];

                if (Schema.SObjectType.OrderItem.isCreateable()) {
                    List<OrderItem> updatedOrderItems = checkExistingOrderItem(
                            orderItems,
                            pricebookEntry[0].Product2Id
                    );
                    if (updatedOrderItems == null) {
                        setPricebookOnOrder(orderId, pricebookEntryId);
                        OrderItem orderItem = new OrderItem();
                        orderItem.OrderId = orderId;
                        orderItem.Product2Id = pricebookEntry[0].Product2Id;
                        orderItem.UnitPrice = pricebookEntry[0].UnitPrice;
                        orderItem.Quantity = 1;
                        orderItem.PricebookEntryId = pricebookEntryId;
                        insert orderItem;
                    } else {
                        update updatedOrderItems;
                    }
                    return true;
                } else {
                    throw new CustomException(Label.Order_Item_Access_Error);
                }
            } catch (Exception ex) {
                throw new CustomException(ex.getMessage());
            }
        }
        throw new customException(Label.Invalid_Arguments);
    }

    /**
     * Method to set the procebookid on the order if it is missing
     * @param orderId order record id
     * @param pricebookEntryId price book Entry Id
     *
     * @return Boolean is the method successful
     */
    private static Boolean setPricebookOnOrder(Id orderId, Id pricebookEntryId) {
        Order order = [
                SELECT Id, Status, Account.AccountNumber, OrderNumber, Type, Pricebook2Id
                FROM order
                WHERE Id = :orderId
                WITH SECURITY_ENFORCED
        ];
        if (order.Pricebook2Id == null) {
            PricebookEntry pricebookEntry = [
                    SELECT Id, Pricebook2Id
                    FROM PricebookEntry
                    WHERE Id = :pricebookEntryId
                    WITH SECURITY_ENFORCED
            ];
            order.Pricebook2Id = pricebookEntry.Pricebook2Id;
            if (Schema.SObjectType.Order.isUpdateable()) {
                update order;
            } else {
                throw new CustomException(Label.Order_Item_Access_Error);
            }
        }
        return true;
    }

    /**
     * Method  to check if  product is already exist in List of Order Items
     * @param orderItems List of OrderItems
     * @param productId record Id of Products
     *
     * @return List of OrderItems
     */
    private static List<OrderItem> checkExistingOrderItem(
            List<OrderItem> orderItems,
            Id productId
    ) {
        if (orderItems != null) {
            for (OrderItem orderItem : orderItems) {
                if (orderItem.Product2Id == productId) {
                    orderItem.Quantity += 1;
                    return orderItems;
                }
            }
        }
        return null;
    }
}
