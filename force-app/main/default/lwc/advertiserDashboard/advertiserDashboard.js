import { LightningElement, track } from 'lwc';
import getInvoices from '@salesforce/apex/AdvertiserPortalController.getInvoices';

export default class AdvertiserDashboard extends LightningElement {
    @track invoices = [];
    filters = {};

    connectedCallback() {
        const raw = window.location.hash.substring(1);
        this.applyFilters(raw);
        this.loadInvoices();
    }

    applyFilters(rawQueryString) {
        rawQueryString.split('&').forEach((pair) => {
            const [key, value] = pair.split('=');
            if (key) {
                this.filters[key] = decodeURIComponent(value || '');
            }
        });
    }

    loadInvoices() {
        getInvoices({ advertiserId: this.filters.advertiserId }).then((data) => {
            this.invoices = data;
            this.renderSummary();
        });
    }

    renderSummary() {
        const note = this.filters.note || '';
        const el = this.template.querySelector('.summary');
        el.innerHTML = '<p>Showing ' + this.invoices.length + ' invoices. ' + note + '</p>';
    }

    handleRedirect() {
        const next = this.filters.next;
        if (next && next.startsWith('https://')) {
            window.open(next, '_blank');
        }
    }

    exportCsv() {
        const rows = this.invoices.map((i) => [i.Name, i.Balance__c].join(','));
        const blob = new Blob([rows.join('\n')], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        window.location.assign(url);
    }
}
