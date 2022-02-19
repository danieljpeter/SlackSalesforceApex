@RestResource(urlMapping='/nexqykdsjgnxujmypbyqkavkmtgsykehvqxutlnbccfujjibpcsirgcmqcki/*')
//https://slackrocks-developer-edition.na213.force.com/ceht3q7h2c8vqkp3qd8gj6wum3skxzsvwz5japp5/services/apexrest/nexqykdsjgnxujmypbyqkavkmtgsykehvqxutlnbccfujjibpcsirgcmqcki

//explict interactions
global without sharing class SlackInteractivityListener {

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

        String outerEventType = '';
        String innerEventType = '';
        String subtype = '';

        Map<String, Object> payloadParamMap = new Map<String, Object>();
        if (params.containsKey('payload')) {
            //block kit button click, etc.
            try {
                payloadParamMap = (Map<String, Object>)JSON.deserializeUntyped(params.get('payload'));
            } catch (Exception e){
            }
        } else if (params.containsKey('command')) {
            //slash command
            outerEventType = 'command';
            innerEventType = params.get('command');
        }

        if (payloadParamMap.containsKey('type')) {
            outerEventType = (String)payloadParamMap.get('type');
        }

        if ( (outerEventType == 'shortcut') || (outerEventType == 'message_action') ) {
            innerEventType = (String)payloadParamMap.get('callback_id');
        }

        insert new Slack_Payload__c(
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
            Body__c         = (!payloadParamMap.keySet().isEmpty()) ? JSON.serializePretty(payloadParamMap) : null
        );


        switch on outerEventType {
            when 'block_actions' {
                blockActionHandler(JSON.serialize(payloadParamMap));
            }
            when 'command' {
                slashCommandHandler(innerEventType, JSON.serialize(params));
            }
            when 'shortcut' {
                shortcutHandler(innerEventType, JSON.serialize(payloadParamMap));
            }
            when 'message_action' {
                shortcutHandler(innerEventType, JSON.serialize(payloadParamMap));
            }
        }


    }

    public static void blockActionHandler(String body) {
        EventBus.publish(
            new Slack_Block_Action__e(
                Payload__c = body
            )
        );
    }

    public static void slashCommandHandler(String slashCommand, String body) {
        Set<String> commandsToHandle = new Set<String>{
            '/dynamodal'
        };

        if (commandsToHandle.contains(slashCommand)) {
            EventBus.publish(
                new Slack_Slash_Command__e(
                    Slash_Command__c    = slashCommand,
                    Payload__c          = body
                )
            );
        }

    }

    public static void shortcutHandler(String shortcut, String body) {
        Set<String> shortcutsToHandle = new Set<String>{
            'lead_count',
            'l33t_speak'
        };

        if (shortcutsToHandle.contains(shortcut)) {
            EventBus.publish(
                new Slack_Shortcut__e(
                    Shortcut_Name__c    = shortcut,
                    Payload__c          = body
                )
            );
        }

    }

}