public class SlackObjects {

    //these could be ported from the java versions here: https://github.com/slackapi/java-slack-sdk/tree/main/slack-api-model/src/main/java/com/slack/api/model

    //=============================================================================
    // common outer wrapper objects for Events API
    //=============================================================================

    public class OuterEvent {
        public String event_context {get; set;}
        public List<Authorization> authorizations {get; set;}
        public Long event_time {get; set;}
        public String event_id {get; set;}
        public String type {get; set;}
        public String api_app_id {get; set;}
        public String team_id {get; set;}
        public String token {get; set;}
        public OuterEvent(){
        }
    }

    public class Authorization {
        public Boolean is_enterprise_install {get; set;}
        public Boolean is_bot {get; set;}
        public String user_id {get; set;}
        public String team_id {get; set;}
        public String enterprise_id {get; set;}
        public Authorization(){
        }
    }

    //=============================================================================
    // message objects.  there are many flavors of these, not including all
    //=============================================================================

    //regular old message.  doesn't have a subtype
    public class Message {
        public String channel_type {get; set;}
        public String event_ts {get; set;}
        public String channel {get; set;}
        //blocks property left out intentionally for simplicity
        public String team {get; set;}
        public String ts {get; set;}
        public String user {get; set;}
        public String text {get; set;}
        public String type {get; set;}
        public String client_msg_id {get; set;}
        public Message(){
        }
    }

}