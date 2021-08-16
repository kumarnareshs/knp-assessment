/**
 * Created by Naresh Kumar on 16/08/2021.
 */

public with sharing class OrderProductsController {
    /**
     * Endpoint of the external service
     */
    private static final String requestEndPoint = 'https://kpn-naresh-test.requestcatcher.com/test';


    /**
     * Method to get order data for the component to render
     * @param sortBy order by column name
     * @param sortDirection order by direction
     * @param orderRecordId order record id
     *
     * @return OrderData with isOrderActivated and orderItems data
     */
    @AuraEnabled(Cacheable=true)
    public static OrderData getOrderData(id orderRecordId, String sortBy, String sortDirection) {
        if (!String.isBlank(orderRecordId) && !String.isBlank(sortBy) && !String.isBlank(sortDirection)) {
            String query = 'SELECT Id,Product2.Name,Quantity,UnitPrice,TotalPrice FROM OrderItem WHERE OrderId =  \'' + orderRecordId + '\'';
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
            List<Order> order = [Select id, status from order where id = :orderRecordId WITH SECURITY_ENFORCED];
            if (order == null || order.size() == 0) {
                throw new customException(Label.Data_Error);
            }
            OrderData returnData = new orderData();
            returnData.isOrderActivated = order[0].status == 'Activated' ? true : false;
            returnData.orderItems = orderItemDTOS;
            return returnData;
        }
        throw new customException(Label.Invalid_Arguments);
    }

    /**
     * Method to activate the order
     * @param orderId order record id
     *
     * @return Boolean if all the operation is successful
     */
    @AuraEnabled
    public static Boolean activateOrderItems(Id orderId) {
        if (!String.isBlank(orderId)) {
            try {
                Order order = new Order();
                if (Schema.SObjectType.OrderItem.isUpdateable()) {
                    if (sendOrder(orderId)) {
                        order.Id = orderId;
                        order.Status = 'Activated';
                        update order;
                    }else {
                        return false;
                    }
                } else {
                    throw new CustomException(Label.Order_Update_Error);
                }
                return true;
            } catch (Exception ex) {
                throw new CustomException(ex.getMessage());
            }
        }
        throw new customException(Label.Invalid_Arguments);
    }

    /**
     * Method to send the orderitems to external system
     * @param orderId order record id
     *
     * @return Boolean if all the operation is successful
     */
    private static Boolean sendOrder(Id orderId) {
        Order order = getOrder(orderId);
        List<OrderDTO.orderProducts> orderProducts = new List<OrderDTO.orderProducts>();
        for (OrderItem orderItem : order.OrderItems) {
            orderProducts.add(new OrderDTO.orderProducts(orderItem.Product2.Name, orderItem.Product2.ProductCode, orderItem.UnitPrice, orderItem.Quantity));
        }

        List<OrderDTO> orderDTOS = new List<OrderDTO>();
        orderDTOS.add(new OrderDTO(order.Account.AccountNumber, order.OrderNumber, order.Type, order.Status, orderProducts));
        return postOrder(JSON.serialize(orderDTOS));
    }

    /**
     * Method to post the order items
     * @param payload payload data to send
     *
     * @return Boolean if all the operation is successful
     */
    private static Boolean postOrder(String payload) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(payload);
        req.setEndpoint(requestEndPoint);
        HttpResponse response = new Http().send(req);
        if (response.getStatusCode() == 200) {
            return true;
        } else {
            throw new CustomException(Label.External_Order_Update_Error);
        }
    }

    /**
     * Method to get the order record
     * @param orderId order id
     *
     * @return Order record
     */
    private static Order getOrder(Id orderId) {
        try {
            Order order = [SELECT Id, Status,Account.AccountNumber,OrderNumber,Type,Pricebook2Id, (SELECT Id,Product2.Name,Quantity,UnitPrice,TotalPrice,Product2.ProductCode FROM OrderItems) FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED];
            return order;
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }

    public class OrderData {
        @AuraEnabled
        public List<OrderItemDTO> orderItems { get; set; }
        @AuraEnabled
        public Boolean isOrderActivated { get; set; }
    }
}
