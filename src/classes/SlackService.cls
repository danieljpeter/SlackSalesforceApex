public with sharing class SlackService {

    public static void agreeWithEverything(String botUserId, SlackObjects.Message message) {
        //make sure we aren't replying to our own messages, this will cause an infinite loop!
        if (message.user != botUserId) {
            SlackWebAPI.replyToMessage(message.channel, message.ts, 'I totally agree!');
        }
    }

    public static void benioffReaction(SlackObjects.Message message) {
        if (message.text.containsIgnoreCase('benioff')) { 
            SlackWebAPI.addReaction(message.channel, message.ts, 'cloud');
        }
    }

    public static void homeTabPublish2(SlackObjects.Message message) {
        SlackBlockKit.View home = new SlackBlockKit.View();
        home.type = 'home';
        home.callback_id = 'home_id';

        SlackBlockKit.Section section1 = new SlackBlockKit.Section();
        section1.block_id = 'section_1';

        String homeText =
        'This is a personalized home tab for *you*.\n\n' +
        'Your Slack User Id is: *'+message.user+'*\n\n-\n\n' +
        'Here are the last 10 Slack Payloads from Salesforce.';

        section1.text = new SlackBlockKit.Text('mrkdwn', homeText);
        home.addBlock(section1);

        home.addBlock(new SlackBlockKit.Divider());

        SlackBlockKit.Section headerRow = new SlackBlockKit.Section();
        headerRow.block_id = 'header';
        List<SlackBlockKit.Text> labels = new List<SlackBlockKit.Text>{
            new SlackBlockKit.Text('Outer Event'),
            new SlackBlockKit.Text('Inner Event')
        };
        headerRow.fields = labels;
        home.addBlock(headerRow);

        home.addBlock(new SlackBlockKit.Divider());

        for (Slack_Payload__c sp: [SELECT Id, Name, Outer_Event__c, Inner_Event__c
                                    FROM Slack_Payload__c
                                    ORDER BY CreatedDate
                                    DESC LIMIT 10]) {

            SlackBlockKit.Section row = new SlackBlockKit.Section();
            row.block_id = sp.Id;
            List<SlackBlockKit.Text> fields = new List<SlackBlockKit.Text>{
                new SlackBlockKit.Text(sp.Name + ' - ' + sp.Outer_Event__c),
                new SlackBlockKit.Text(sp.Inner_Event__c)
            };
            row.fields = fields;
            home.addBlock(row);
        }

        SlackWebAPI.publishView(message.user, home);
    }

    public static void homeTabPublish(SlackObjects.Message message) {
        String template = [SELECT Id, Block_Kit_JSON__c FROM Slack_Block_Kit_Template__c WHERE Name='hotels'][0].Block_Kit_JSON__c;
        template = template.replace('{!price}', '$210');

        SlackWebAPI.publishView(message.user, template);
    }

    public static void blockKitReaction(SlackObjects.Message message) {
        if (message.text.containsIgnoreCase('block kit')) {
            SlackBlockKit.Layout layout = new SlackBlockKit.Layout();

            SlackBlockKit.Section headerSection = new SlackBlockKit.Section();
            headerSection.text = new SlackBlockKit.Text('mrkdwn', 'Did someone ask to see some *Block Kit*?');

            layout.addBlock(headerSection);
            layout.addBlock(new SlackBlockKit.Divider());

            SlackBlockKit.Section imageSection = new SlackBlockKit.Section();

            String imageSectionText =
            ':tada:  This is a *Daniel Peter* at *Dreamforce 2015*.\n' +
            ':heart: Who loves *SaaSy*?\n' +
            ':eyes:  SaaSy is on twitter as *@TooSaaSy*\n' +
            ':clap:  Hope to see you at a future Dreamforce.';

            imageSection.text = new SlackBlockKit.Text('mrkdwn', imageSectionText);
            SlackBlockKit.Accessory imageAccessory = new SlackBlockKit.Accessory();
            imageAccessory.type = 'image';
            imageAccessory.image_url = 'https://slackrocks-developer-edition.na213.force.com/ceht3q7h2c8vqkp3qd8gj6wum3skxzsvwz5japp5/resource/1645224128000/toosaasy';
            imageAccessory.alt_text = 'Too SaaSy';
            imageSection.accessory = imageAccessory;

            layout.addBlock(imageSection);
            layout.addBlock(new SlackBlockKit.Divider());

            SlackBlockKit.Actions actions = new SlackBlockKit.Actions();

            SlackBlockKit.Button theBest = new SlackBlockKit.Button();
            theBest.text = new SlackBlockKit.Text('plain_text', 'That guy is tops!');
            theBest.value = 'action-tops-value';
            theBest.action_id = 'action-tops-id';
            actions.addAction(theBest);

            SlackBlockKit.Button theWorst = new SlackBlockKit.Button();
            theWorst.text = new SlackBlockKit.Text('plain_text', 'I\'m not impressed');
            theWorst.value = 'action-worst-value';
            theWorst.action_id = 'action-worst-id';
            actions.addAction(theWorst);

            layout.addBlock(actions);

            system.debug('*** layout: ' + JSON.serialize(layout));

            SlackWebAPI.postMessage(message.channel, 'Pssst... Check this out!', layout);
        }
    }


    public static void createDynaBlockModal(String body) {
        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        Integer size = Integer.valueOf((String)bodyMap.get('text'));
        String triggerId = (String)bodyMap.get('trigger_id');

        SlackBlockKit.View dynaModal = new SlackBlockKit.View();
        dynaModal.callback_id = 'dynamodal_id';
        dynaModal.title = new SlackBlockKit.Text('plain_text', 'Dynamodal Sections: ' + size);
        for (Integer i=0; i<size; i++) {
            SlackBlockKit.Section section = new SlackBlockKit.Section();
            section.block_id = 'section_'+i;
            section.text = new SlackBlockKit.Text('mrkdwn', 'Section Number *'+i+'*.');
            dynaModal.addBlock(section);
        }
        SlackWebAPI.openView(triggerId, dynaModal);
    }



}