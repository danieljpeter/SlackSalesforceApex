public with sharing class SlackShortcutHandler {

    public static void handleShortcuts(List<Slack_Shortcut__e> shortcuts) {
        for (Slack_Shortcut__e s: shortcuts) {
            switch on s.Shortcut_Name__c {
                when 'lead_count' {
                    handleLeadCount(s);
                }
                when 'l33t_speak' {
                    handleL33tSpeak(s);
                }
            }
        }
    }

    public static void handleLeadCount(Slack_Shortcut__e shortcut) {
        Map<String, Object> shortcutObj = (Map<String, Object>)JSON.deserializeUntyped(shortcut.Payload__c);
        String triggerId = (String)shortcutObj.get('trigger_id');

        SlackBlockKit.View leadCountModal = new SlackBlockKit.View();
        leadCountModal.callback_id = 'leadcountmodal_id';
        leadCountModal.title = new SlackBlockKit.Text('plain_text', 'Leads in Salesforce');

        SlackBlockKit.Section section = new SlackBlockKit.Section();
        section.block_id = 'section_1';
        section.text = new SlackBlockKit.Text('mrkdwn', 'There are *'+[SELECT COUNT() FROM Lead]+'* Leads in Salesforce.');
        leadCountModal.addBlock(section);

        SlackWebAPI.openView(triggerId, leadCountModal);
    }

    public static void handleL33tSpeak(Slack_Shortcut__e shortcut) {
        Map<String, Object> shortcutObj = (Map<String, Object>)JSON.deserializeUntyped(shortcut.Payload__c);
        String messageTS = (String)shortcutObj.get('message_ts');
        String channel = (String)((Map<String, Object>)shortcutObj.get('channel')).get('id');
        String text = (String)((Map<String, Object>)shortcutObj.get('message')).get('text');

        String finalMsg =
        'Original text: \n' +
        '`' + text + '`\n\n' +
       'l33t speak ya n00b: \n' +
        '```' + L33tTranslator.translate(text) + '```';

        SlackWebAPI.replyToMessage(channel, messageTS, finalMsg);
    }


}