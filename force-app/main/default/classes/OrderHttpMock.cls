/**
 * Created by naresh on 16/08/2021.
 */

public inherited sharing class OrderHttpMock implements HttpCalloutMock {

    public static Boolean successResponse = false;

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(successResponse)res.setStatusCode(200);
        else res.setStatusCode(201);
        return res;
    }

}