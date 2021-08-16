public with sharing class AvailableProductsController {
    public AvailableProductsController() {

    }


    @AuraEnabled(Cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(String sortBy, String sortDirection, String search){
        if(!String.isBlank(sortBy) && !String.isBlank(sortDirection)){

        String defaultPricebookName = Label.Default_Pricebook_Name;
        Pricebook2 pricebook = [Select id from Pricebook2 where name =:defaultPricebookName];
        String query = 'SELECT Name,Id,UnitPrice,Product2Id,Pricebook2Id FROM PricebookEntry '+
        'WHERE IsActive = TRUE AND Pricebook2Id =:pricebook.id ';
        if(!String.isBlank(search)){
            query += ' Name like %'+Search+'%';
        }
        query += ' WITH SECURITY_ENFORCED ';
        query += ' ORDER BY '+sortBy +' '+sortDirection;

        return Database.query(query);

    }
    throw new customException(Label.Invalid_Arguments);
    }
}
