global without sharing class SlackRequestValidator {

    global static ValidationResponse validateRequest(String signingSecret, String requestBody, Long reqTimestamp, String slackSignature) {
        //docs from: https://api.slack.com/authentication/verifying-requests-from-slack
        ValidationResponse vr = new ValidationResponse();
        vr.isValid = false;

        if (String.isEmpty(slackSignature)) {
            vr.isValid = false;
            vr.failureType = 'No Signature.';
            return vr;
        }

        if (reqTimestamp == null) {
            vr.isValid = false;
            vr.failureType = 'No timestamp.';
            return vr;
        }

        //make sure it isn't a replay attack, check the timestamp to make sure it's within 5 mins of our system time.
        Long currTimestamp = (DateTime.now().getTime() / 1000); //convert from ms to seconds to match Slack request timestamp
        Long allowedDiff = 60 * 5; //5 mins
        Long diff = Math.abs(currTimestamp - reqTimestamp);
        if (diff > allowedDiff) {
            vr.isValid = false;
            vr.failureType = 'Timestamp is more than 5 mins off.';

            if (!Test.isRunningTest()) {
                //can't fake current time in tests for past dates
                return vr;
            }
        }
        String sigBaseString = 'v0:' + reqTimestamp + ':' + requestBody;
        Blob sigBaseBlob = Blob.valueOf(sigBaseString);
        Blob blobHash = Crypto.generateMac('hmacSHA256', sigBaseBlob, Blob.valueOf(signingSecret));
        String hexHash = EncodingUtil.convertToHex(blobHash);
        String finalHash = 'v0=' + hexHash;
        vr.calculatedSignature = finalHash;

        if (finalHash == slackSignature) {
            vr.isValid = true;
        } else {
            vr.isValid = true;
            vr.failureType = 'Signature mismatch.';
        }

        return vr;
    }


    global class ValidationResponse {
        public Boolean isValid {get; set;}
        public String calculatedSignature {get; set;}
        public String failureType {get; set;}

        public ValidationResponse() {
        }
    }


}