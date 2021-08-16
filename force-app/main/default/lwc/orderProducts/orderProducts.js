/**
 * Created by Naresh Kumar on 16/08/2021.
 */

import {LightningElement, api, wire} from "lwc";
import {showToastNotification} from "c/util";
import {LABELS} from "c/constant";
import getOrderData from "@salesforce/apex/OrderProductsController.getOrderData";
import activateOrderItems from "@salesforce/apex/OrderProductsController.activateOrderItems";

const COLUMNS = [
    {label: "Name", fieldName: "Name", type: "text", sortable: true},
    {
        label: "Unit Price",
        fieldName: "unitPrice",
        type: "currency",
        sortable: true
    },
    {label: "Quantity", fieldName: "quantity", type: "number", sortable: true},
    {
        label: "Total Price",
        fieldName: "totalPrice",
        type: "currency",
        sortable: true
    }
];

import {refreshApex} from "@salesforce/apex";
// Import message service features required for subscribing and the message channel
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext, publish
} from "lightning/messageService";
import orderMessage from "@salesforce/messageChannel/orderMessage__c";

export default class OrderProducts extends LightningElement {
    subscription = null;
    sortBy = LABELS.Order_Sort_Column;
    sortDirection = LABELS.Order_Sort_Direction;
    lstOrders;
    showSpinner = true;
    labels = LABELS;
    @api height = 250;
    lstOrderColumns = COLUMNS;
    @api recordId;
    _orderResponse;
    @wire(MessageContext)
    messageContext;
    isActivated = true;

    get dataTableStyle() {
        return "height: " + this.height + "px;";
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                orderMessage,
                (message) => this.handleMessage(message),
                {scope: APPLICATION_SCOPE}
            );
            console.log(this.subscription);
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    @wire(getOrderData, {
        orderRecordId: "$recordId",
        sortBy: "$sortBy",
        sortDirection: "$sortDirection"
    })
    wiredOrderResponse(result) {
        this._orderResponse = result;
        this.showSpinner = true;
        if (result.data) {
            this.lstOrders = result.data.orderItems;
            this.isActivated = result.data.isOrderActivated;
        } else if (result.error) {
            showToastNotification(
                this,
                LABELS.Error_Title,
                result.error.body.message,
                "Error"
            );
        }
        this.showSpinner = false;
    }

    handleSort(event) {
        this.showSpinner = true;

        if (event.detail.fieldName == 'Name') {
            this.sortBy = 'Product2.Name';
        } else {
            this.sortBy = event.detail.fieldName;
        }
        this.sortDirection = event.detail.sortDirection;
    }

    // Handler for message received by component
    handleMessage(message) {
        console.log("handle message" + message);
        if (message.message.refresh) {
            this.showSpinner = true;
            refreshApex(this._orderResponse);
        }
    }

    handleActivateClick(event) {
        this.showSpinner = true;
        activateOrderItems({
            orderId: this.recordId
        })
            .then((result) => {
                if (result) {
                    this.isActivated = true;
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                showToastNotification(
                    this,
                    LABELS.Error_Title,
                    error.body.message,
                    "Error"
                );
                this.showSpinner = false;
            });
    }
}
