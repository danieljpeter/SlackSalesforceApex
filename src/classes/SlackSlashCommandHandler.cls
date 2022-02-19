public with sharing class SlackSlashCommandHandler {

    public static void handleSlashCommands(List<Slack_Slash_Command__e> commands) {
        for (Slack_Slash_Command__e c: commands) {
            switch on c.Slash_Command__c {
                when '/dynamodal' {
                    handleDynaModal(c);
                }
            }
        }
    }

    public static void handleDynaModal(Slack_Slash_Command__e command) {
        SlackService.createDynaBlockModal(command.Payload__c);
    }


}