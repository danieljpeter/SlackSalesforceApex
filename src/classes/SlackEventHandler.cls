public with sharing class SlackEventHandler {

    static final String BOT_USER_ID = [SELECT Bot_User_Id__c FROM Slack_App__mdt LIMIT 1][0].Bot_User_Id__c;

    public static void handleSlackEvents(List<Slack_Event__e> events) {
        for (Slack_Event__e se: events) {
            EventParts ep = splitEventWrapper(se);
            switch on se.Event_Type__c {
                when 'member_joined_channel' {
                    handleMemberJoinedChannel(ep);
                }
                when 'member_left_channel' {
                    handleMemberLeftChannel(ep);
                }
                when 'message' {
                    handleMessage(ep);
                }
                when 'reaction_added' {
                    handleReactionAdded(ep);
                }
                when 'reaction_removed' {
                    handleReactionRemoved(ep);
                }
                when 'app_home_opened' {
                    handleAppHomeOpened(ep);
                }
            }
        }
    }


    public static void handleMemberJoinedChannel(EventParts ep) {
    }

    public static void handleMemberLeftChannel(EventParts ep) {
    }

    public static void handleMessage(EventParts ep) {
        SlackObjects.Message message = (SlackObjects.Message) JSON.deserialize(JSON.serialize(ep.innerEvent), SlackObjects.Message.class);

        SlackService.agreeWithEverything(BOT_USER_ID, message);
        SlackService.benioffReaction(message);
        SlackService.blockKitReaction(message);
    }

    public static void handleReactionAdded(EventParts ep) {
    }

    public static void handleReactionRemoved(EventParts ep) {
    }

    public static void handleAppHomeOpened(EventParts ep) {
        SlackObjects.Message message = (SlackObjects.Message) JSON.deserialize(JSON.serialize(ep.innerEvent), SlackObjects.Message.class);
        SlackService.homeTabPublish(message);
    }

    public static EventParts splitEventWrapper(Slack_Event__e event) {
        //split out the outer event (comment wrapper) and the inner event (many flavors)
        EventParts ep = new EventParts();
        Map<String, Object> eventObj = (Map<String, Object>)JSON.deserializeUntyped(event.Payload__c);
        String innerEventJSON = JSON.serialize(eventObj.get('event'));
        eventObj.remove('event');

        ep.innerEventType = event.Event_Type__c;
        ep.outerEvent = (SlackObjects.OuterEvent)JSON.deserialize(JSON.serialize(eventObj), SlackObjects.OuterEvent.class);
        ep.innerEvent = JSON.deserializeUntyped(innerEventJSON);
        return ep;
    }

    public class EventParts {
        public SlackObjects.OuterEvent outerEvent {get; set;}
        public String innerEventType {get; set;}
        public String innerEventSubType {get; set;}
        public Object innerEvent {get; set;}
        public EventParts() {
        }
    }

}