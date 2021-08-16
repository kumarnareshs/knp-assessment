public inherited sharing class OrderItemDTO {
  @AuraEnabled
  public String product2Id;
  @AuraEnabled
  public String Name;
  @AuraEnabled
  public Decimal unitPrice;
  @AuraEnabled
  public Decimal quantity;
  @AuraEnabled
  public Decimal totalPrice;

  public OrderItemDTO(
    String product2Id,
    String orderItemName,
    Decimal unitPrice,
    Decimal quantity,
    Decimal totalPrice
  ) {
    this.product2Id = product2Id;
    this.Name = orderItemName;
    this.unitPrice = unitPrice;
    this.quantity = quantity;
    this.totalPrice = totalPrice;
  }
}
