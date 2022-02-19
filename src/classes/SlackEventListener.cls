@RestResource(urlMapping='/397dgjv9z4e7n5m8t3kkukuptqp37ua2pwu4zxp7rceqvkrxhy3zusdz6ej2/*')
//https://slackrocks-developer-edition.na213.force.com/ceht3q7h2c8vqkp3qd8gj6wum3skxzsvwz5japp5/services/apexrest/397dgjv9z4e7n5m8t3kkukuptqp37ua2pwu4zxp7rceqvkrxhy3zusdz6ej2

//implicit interactions
global without sharing class SlackEventListener {

    @HttpPost
    global static void handlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;

        Map<String, String> headers = req.headers;
        String httpMethod           = req.httpMethod;
        String remoteAddress        = req.remoteAddress;
        String requestURI           = req.requestURI;
        String resourcePath         = req.resourcePath;
        Map<String, String> params  = req.params;   //used by events
        String body                 = req.requestBody?.toString(); //used by URL verification / challenge

        Map<String, Object> bodyMap = new Map<String, Object>();
        try {
            bodyMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        } catch (Exception e){
        }

        Slack_App__mdt config = [SELECT App_Id__c, Client_Id__c, Client_Secret__c, Signing_Secret__c, Verification_Token__c FROM Slack_App__mdt LIMIT 1][0];
        Long reqTimestamp = headers.containsKey('X-Slack-Request-Timestamp') ? Long.valueOf(headers.get('X-Slack-Request-Timestamp')) : null;
        String slackSignature = headers.containsKey('X-Slack-Signature') ? headers.get('X-Slack-Signature') : null;

        SlackRequestValidator.ValidationResponse vr = SlackRequestValidator.validateRequest(config.Signing_Secret__c, body, reqTimestamp, slackSignature);

        String outerEventType = '';
        if (bodyMap.containsKey('type')) {
            outerEventType = (String)bodyMap.get('type');
        }

        String innerEventType = '';
        String subtype = '';
        if (bodyMap.containsKey('event')) {
            Map<String, Object> eventObj = (Map<String, Object>)bodyMap.get('event');
            innerEventType = (String)eventObj.get('type');
            if (eventObj.containsKey('subtype')) {
                subtype = (String)eventObj.get('subtype');
            }
        }

        insert new Slack_Payload__c(
            Calculated_Signature__c                 = vr.calculatedSignature,
            Signed_Request_Verification_Passed__c   = vr.isValid,
            Verification_Failure__c                 = vr.failureType,
            Outer_Event__c  = outerEventType,
            Inner_Event__c  = innerEventType,
            Subtype__c      = subtype,
            Headers__c      = (headers != null) ? JSON.serializePretty(headers) : null,
            HTTP_Method__c  = httpMethod,
            Remote_IP__c    = remoteAddress,
            Request_URI__c  = requestURI,
            Path__c         = resourcePath,
            Params__c       = (params != null) ? JSON.serializePretty(params) : null,
            Raw_Body_Hex__c = (req.requestBody) != null ? EncodingUtil.convertToHex(req.requestBody) : null,
            Raw_Body__c     = body,
            Body__c         = (!bodyMap.keySet().isEmpty()) ? JSON.serializePretty(bodyMap) : null
        );

        if (!vr.isValid) {
            //failed signature validation, possible hacking attempt
            res.statusCode = 401;
            return;
        }

        switch on outerEventType {
            when 'url_verification' {
                //first time setting up an Events Endpoint, this gets invoked to make sure it's legit
                urlVerification(res, bodyMap);
            }
            when 'event_callback' {
                eventHandler(body, innerEventType);
            }
        }

    }


    public static void urlVerification(RestResponse res, Map<String, Object> bodyParams) {
        //echo back the challenge value from the parameters in the body
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf((String)bodyParams.get('challenge'));
    }

    public static void eventHandler(String body, String eventType) {
        Set<String> eventsToHandle = new Set<String>{
            'member_joined_channel',
            'member_left_channel',
            'message',
            'reaction_added',
            'reaction_removed',
            'app_home_opened'
        };
        if (eventsToHandle.contains(eventType)) {
            EventBus.publish(
                new Slack_Event__e(
                    Event_Type__c   = eventType,
                    Payload__c      = body
                )
            );
        }
    }




}