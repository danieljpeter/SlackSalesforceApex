trigger SlackSlashCommand on Slack_Slash_Command__e (after insert) {

    system.debug('*** SlackSlashCommand: ' + JSON.serialize(Trigger.New));

    SlackSlashCommandHandler.handleSlashCommands(Trigger.New);

}