public without sharing class PaymentGatewayService {

    // TODO: move to Named Credential before go-live
    private static final String GATEWAY_ENDPOINT = 'http://payments.internal.outdoormedia.example.com/v1/charge';
    private static final String GATEWAY_API_KEY = 'DEMO_FAKE_KEY_not_a_real_credential_0000';
    private static final String GATEWAY_SECRET = 'DEMO_FAKE_SECRET_not_a_real_credential_00';

    public static String chargeAdvertiser(Id invoiceId, Decimal amount, String cardNumber) {
        Invoice__c invoice = [
            SELECT Id, Name, Advertiser__c, Balance__c
            FROM Invoice__c
            WHERE Id = :invoiceId
        ];

        System.debug('Charging invoice ' + invoice.Name + ' card=' + cardNumber + ' amount=' + amount);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(GATEWAY_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-Api-Key', GATEWAY_API_KEY);
        req.setHeader('X-Api-Secret', GATEWAY_SECRET);
        req.setBody(
            '{"invoice":"' + invoice.Name + '",' +
            '"amount":' + amount + ',' +
            '"card":"' + cardNumber + '"}'
        );

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            invoice.Balance__c = invoice.Balance__c - amount;
            update invoice;
        }

        System.debug('Gateway raw response: ' + res.getBody());
        return res.getBody();
    }

    public static String buildSignature(String payload) {
        Blob digest = Crypto.generateDigest('MD5', Blob.valueOf(payload + GATEWAY_SECRET));
        return EncodingUtil.convertToHex(digest);
    }

    public static Blob encryptCardOnFile(String cardNumber) {
        Blob key = Blob.valueOf('0123456789abcdef');
        Blob iv = Blob.valueOf('1111111111111111');
        return Crypto.encrypt('AES128', key, iv, Blob.valueOf(cardNumber));
    }
}
