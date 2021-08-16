//import methods
import { LightningElement, track, wire, api } from 'lwc';
import {showToastNotification} from 'c/util';
import {LABELS} from 'c/constant';
// import { refreshApex } from "@salesforce/apex";
// import { MessageEventController } from "c/messageEventController";
// import MessagingService from '@salesforce/messageChannel/orderMessage__c';

// //import controller
// import getPricebooks from '@salesforce/apex/AvailableProductsController.getPricebooks';
// import getOrder from '@salesforce/apex/OrderProductsController.getOrder';
// import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
// import getAvailableOrderItems from '@salesforce/apex/OrderProductsController.getAvailableOrderItems';
// import { APPLICATION_SCOPE, MessageContext, subscribe } from "lightning/messageService";

//import getPricebooks from '@salesforce/apex/AvailableProductsController.getPricebooks';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
const COLUMNS = [
    {label: '',
        type: 'button-icon',
        initialWidth: 75,
        typeAttributes: {
            iconName: 'utility:add',
            title: 'Add',
            variant: 'border-filled',
            alternativeText: 'View',
        }
    },
    {label: 'Name',fieldName: 'Name',type: 'text'},
    {label: 'List Price',fieldName: 'UnitPrice',type: 'currency'}
];

export default class AvailableProducts extends LightningElement {



    sortBy = LABELS.Product_Sort_Column;
    sortDirection =LABELS.Product_Sort_Direction;
    search;
    lstProductColumns;  
    lstAvailableProducts;
    showSpinner = true;
    labels = LABELS;
    
    lstProductColumns = COLUMNS;
    connectedCallback() {
       
    }

    // @wire(getColumnData)
    // getColumnData({error, data}) {
    //     if (data) {
    //         this.lstDataTableColumns = data
    //     } else if (error) {
    //         showToastNotification(this, LABELS.Error_Title, error.body.message, 'Error');
    //     }
    // }

    @wire(getAvailableProducts, {
        sortBy: '$sortBy',
        sortDirection: '$sortDirection',
        search: '$search'
    })
    getAvailableProducts({error, data}) {
        this.serverResponse = data;
        this.showSpinner = true;
        if (data) {
            this.lstAvailableProducts = data;
        } else if (error) {
            showToastNotification(this, LABELS.Error_Title, error.body.message, 'Error');
        }
        this.showSpinner = false;

    }

    handleSort(event) {
        this.showSpinner = true;
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    }

    handleSearch(event) {
        this.showSpinner = true;
        this.search = event.detail.value;
    }

}