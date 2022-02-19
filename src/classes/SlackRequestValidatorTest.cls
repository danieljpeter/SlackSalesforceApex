@isTest
private class SlackRequestValidatorTest {

    @isTest static void testMethod1() {
        Slack_App__mdt config = [SELECT App_Id__c, Client_Id__c, Client_Secret__c, Signing_Secret__c, Verification_Token__c FROM Slack_App__mdt LIMIT 1][0];
        String body = '{"token":"ZADSCTobsqaorgazzdvH8Bo6","challenge":"4W9isdAiYNxCZwwXfMIL2vjFByPoXwxGK0vEGshOThGQvvBTl31y","type":"url_verification"}';
        String signature = 'v0=a44159151bd3605f2569c7e5f56766c5f90b3c34ebd0e30e9ea25b7818387896';
        //Long currTimestamp = (DateTime.now().getTime() / 1000);
        Long currTimestamp = 1642386652;

        SlackRequestValidator.ValidationResponse vr = SlackRequestValidator.validateRequest(config.Signing_Secret__c, body, currTimestamp, signature);
        system.assertEquals(true, vr.isValid, 'Expected happy path to succeed.');
    }

}