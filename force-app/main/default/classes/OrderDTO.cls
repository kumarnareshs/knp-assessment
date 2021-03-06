/**
 * Created by Naresh Kumar on 16/08/2021.
 * Order DTO to generate JSON for external system
 */

public class OrderDTO {

    public String accountNumber;
    public String orderNumber;
    public String type;
    public String status;
    public List<orderProducts> orderProducts2;

    public OrderDTO(String accountNumber, String orderNumber,String type,String  status, List<orderProducts> orderProducts ){
        this.accountNumber = accountNumber;
        this.orderNumber = orderNumber;
        this.type = type;
        this.status  = status;
        this.orderProducts2 = orderProducts;

    }

    public class orderProducts{
        public  String name;
        public  String code;
        public  Decimal unitPrice;
        public  Decimal quantity;

        public orderProducts(String name,  String code, Decimal unitPrice,Decimal quantity){
            this.name = name;
            this.code = code;
            this.unitPrice = unitPrice;
            this.quantity = quantity;
        }

    }


}