import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import BK_FIELD from '@salesforce/schema/Slack_Block_Kit_Template__c.Block_Kit_JSON__c';
const fields = [BK_FIELD];

export default class Blockkitbuilderlink extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    bk;

    get bkHref() {
        let URL =
        'https://app.slack.com/block-kit-builder/T024GE9EL#' +
        encodeURI(getFieldValue(this.bk.data, BK_FIELD));

        return URL;
    }

}