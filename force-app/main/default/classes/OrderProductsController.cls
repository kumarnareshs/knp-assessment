public with sharing class OrderProductsController {
    @AuraEnabled(Cacheable=true)
    public static OrderData getOrderData(id orderRecordId, String sortBy, String sortDirection) {
        String query =
                'SELECT Id,Product2.Name,Quantity,UnitPrice,TotalPrice FROM OrderItem WHERE OrderId =  \'' +
                        orderRecordId +
                        '\'';
        query += ' WITH SECURITY_ENFORCED ';
        query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        List<OrderItem> orderItems = database.query(query);
        List<OrderItemDTO> orderItemDTOS = new List<OrderItemDTO>();
        for (OrderItem orderItem : orderItems) {
            orderItemDTOS.add(
                    new OrderItemDTO(
                            orderItem.Product2Id,
                            orderItem.Product2.Name,
                            orderItem.UnitPrice,
                            orderItem.Quantity,
                            orderItem.TotalPrice
                    )
            );
        }
        List<Order> order = [Select id, status from order where id = :orderRecordId];
        OrderData returnData = new orderData();
        returnData.isOrderActivated = order[0].status == 'Activated' ? true : false;
        returnData.orderItems = orderItemDTOS;
        return returnData;
    }

    @AuraEnabled
    public static Order activateOrderItems(Id orderId) {
        try {
            system.debug(orderId);
            Order order = new Order();
            if (Schema.SObjectType.OrderItem.isUpdateable()) {
                if (sendOrder(orderId)) {
                order.Id = orderId;
                order.Status = 'Activated';
                update order;
                 }
            } else {
                throw new CustomException(Label.Order_Update_Error);
            }
            return order;
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }

    /**
 * Method to send Order to request catcher
 * @param orderId
 */
    private static Boolean sendOrder(Id orderId){
        Order order = getOrder(orderId);
        List<OrderDTO.orderProducts> orderProducts = new List<OrderDTO.orderProducts>();
        for(OrderItem orderItem : order.OrderItems){
            orderProducts.add(new OrderDTO.orderProducts(orderItem.Product2.Name,orderItem.Product2.ProductCode,orderItem.UnitPrice,orderItem.Quantity));
        }

        List<OrderDTO> orderDTOS  = new List<OrderDTO>();
        orderDTOS.add(new OrderDTO(order.Account.AccountNumber,order.OrderNumber,order.Type,order.Status,orderProducts));
        return PostOrders.postOrder(JSON.serialize(orderDTOS));
    }


    private static Order getOrder(Id orderId){
        try {
            Order order = [SELECT Id, Status,Account.AccountNumber,OrderNumber,Type,Pricebook2Id,(SELECT Id,Product2.Name,Quantity,UnitPrice,TotalPrice,Product2.ProductCode FROM OrderItems) FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED];
            return order;
        } catch (Exception ex){
            throw new CustomException(ex.getMessage());
        }
    }

    class OrderData {
        @AuraEnabled
        public List<OrderItemDTO> orderItems { get; set; }
        @AuraEnabled
        public Boolean isOrderActivated { get; set; }
    }
}
