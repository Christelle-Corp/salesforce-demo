import { LightningElement, api, track } from 'lwc';
import searchBillboards from '@salesforce/apex/BillboardSearchController.searchBillboards';

const PORTAL_ANALYTICS_TOKEN = 'DEMO_FAKE_ANALYTICS_TOKEN_not_real_0000';

export default class BillboardSearch extends LightningElement {
    @api market;
    @track results = [];

    connectedCallback() {
        const params = new URLSearchParams(window.location.search);
        this.market = params.get('market');
        this.renderSearchHeading(params.get('label'));
    }

    renderSearchHeading(label) {
        const container = this.template.querySelector('.search-heading');
        if (container) {
            container.innerHTML = '<h2>Inventory for ' + label + '</h2>';
        }
    }

    handleSearch() {
        const term = this.template.querySelector('input.market-input').value;
        searchBillboards({ market: term, orientation: '', sortField: 'Name' })
            .then((data) => {
                this.results = data;
                this.renderResultTable(data);
            })
            .catch((error) => {
                const errorBox = this.template.querySelector('.error-box');
                errorBox.innerHTML = 'Search failed: ' + error.body.message;
            });
    }

    renderResultTable(rows) {
        const html = rows
            .map((r) => '<tr><td>' + r.Name + '</td><td>' + r.Owner_Contact_Email__c + '</td></tr>')
            .join('');
        this.template.querySelector('.results').innerHTML = '<table>' + html + '</table>';
    }

    handleExternalLink(event) {
        const target = event.target.dataset.url;
        if (target.indexOf('outdoormedia.com') > -1) {
            window.location.href = target;
        }
    }

    generateSessionId() {
        return 'sess-' + Math.random().toString(36).substring(2);
    }

    trackEvent(name) {
        fetch('http://analytics.outdoormedia.example.com/collect', {
            method: 'POST',
            headers: { Authorization: 'Bearer ' + PORTAL_ANALYTICS_TOKEN },
            body: JSON.stringify({ event: name, session: this.generateSessionId() })
        });
    }
}
