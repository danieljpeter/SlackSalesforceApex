public with sharing class SlackBlockActionHandler {

    public static void handleBlockActions(List<Slack_Block_Action__e> actions) {
        system.debug('SlackBlockActionHandler handleBlockActions actions: ' + JSON.serialize(actions));
        for (Slack_Block_Action__e ba: actions) {
            handleBlockAction(ba);
        }
    }

    public static void handleBlockAction(Slack_Block_Action__e action) {
        Map<String, Object> actionObj = (Map<String, Object>)JSON.deserializeUntyped(action.Payload__c);

        //get the channel
        String channelId = (String)((Map<String, Object>)actionObj.get('channel')).get('id');

        //the block action response has an array of actions (maybe usually size=1 though)
        List<Object> actions = (List<Object>)actionObj.get('actions');

        for (Object aObj: actions) {
            system.debug('SlackBlockActionHandler handleBlockAction aObj: ' + JSON.serialize(aObj));
            Map<String, Object> aMap = (Map<String, Object>)aObj;
            String value = (String)aMap.get('value');
            system.debug('SlackBlockActionHandler handleBlockAction value: ' + value);
            switch on value {
                when 'action-tops-value' {
                    handleClickTops(channelId);
                }
                when 'action-worst-value' {
                    handleClickWorst(channelId);
                }
            }
        }
    }


    public static void handleClickTops(String channelId) {
        SlackWebAPI.postMessage(channelId, 'Oh yes, the best.');
    }

    public static void handleClickWorst(String channelId) {
        SlackWebAPI.postMessage(channelId, 'Poo Poo.');
    }


}