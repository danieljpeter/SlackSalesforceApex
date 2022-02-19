trigger SlackBlockAction on Slack_Block_Action__e (after insert) {

    system.debug('SlackBlockAction Trigger.New: ' + JSON.serialize(Trigger.New));
    SlackBlockActionHandler.handleBlockActions(Trigger.New);

}