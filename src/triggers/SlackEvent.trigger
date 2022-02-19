trigger SlackEvent on Slack_Event__e (after insert) {

    SlackEventHandler.handleSlackEvents(Trigger.New);

}