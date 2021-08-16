public with sharing class OrderProductsController {
  @AuraEnabled(Cacheable=true)
  public static List<OrderItemDTO> getCurrentOrderItems(
    id orderRecordId,
    String sortBy,
    String sortDirection
  ) {
    String query =
      'SELECT Id,Name,Quantity,UnitPrice,TotalPrice FROM OrderItem WHERE OrderId =  \'' +
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
          orderItem.Name,
          orderItem.UnitPrice,
          orderItem.Quantity,
          orderItem.TotalPrice
        )
      );
    }
    return orderItemDTOS;
  }
}
