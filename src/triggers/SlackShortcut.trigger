trigger SlackShortcut on Slack_Shortcut__e (after insert) {


    SlackShortcutHandler.handleShortcuts(Trigger.New);

}