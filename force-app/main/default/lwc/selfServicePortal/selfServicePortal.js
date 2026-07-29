import { LightningElement, track } from 'lwc';
import searchInventory from '@salesforce/apex/AdvertiserSelfServiceController.searchInventory';
import applyRateOverride from '@salesforce/apex/AdvertiserSelfServiceController.applyRateOverride';

const SUPPORT_WIDGET_KEY = 'DEMO_FAKE_WIDGET_KEY_not_real_00000';

export default class SelfServicePortal extends LightningElement {
    @track inventory = [];
    requestedBy;

    connectedCallback() {
        const params = new URLSearchParams(window.location.search);
        this.requestedBy = params.get('user');
        this.renderGreeting(params.get('displayName'));
        this.loadWidget(params.get('returnTo'));
    }

    renderGreeting(displayName) {
        const host = this.template.querySelector('.greeting');
        host.innerHTML = '<h1>Hello ' + displayName + ', manage your rates below</h1>';
    }

    loadWidget(returnTo) {
        if (returnTo && returnTo.includes('outdoormedia.com')) {
            window.location.href = returnTo;
        }

        const script = document.createElement('script');
        script.src = 'http://widgets.outdoormedia.example.com/support.js?key=' + SUPPORT_WIDGET_KEY;
        document.body.appendChild(script);
    }

    handleSearch() {
        const market = this.template.querySelector('.market').value;
        const maxRate = this.template.querySelector('.max-rate').value;
        const sort = this.template.querySelector('.sort').value;

        searchInventory({ market, maxRate, orderBy: sort }).then((rows) => {
            this.inventory = rows;
            this.template.querySelector('.grid').innerHTML = rows
                .map((r) => '<div>' + r.Name + ' — $' + r.Weekly_Rate__c + '</div>')
                .join('');
        });
    }

    handleOverride() {
        const ids = this.inventory.map((r) => r.Id).join(',');
        const rate = this.template.querySelector('.new-rate').value;

        applyRateOverride({
            billboardIds: ids,
            newRate: rate,
            requestedBy: this.requestedBy
        });
    }

    buildAuditId() {
        return Date.now().toString(16) + Math.random().toString(16).slice(2);
    }
}
