/**
 * Created by Naresh Kumar on 16/08/2021.
 */

//import methods
import {LightningElement, api, wire} from "lwc";
import {showToastNotification} from "c/util";
import {LABELS} from "c/constant";
import {refreshApex} from "@salesforce/apex";

//import controller
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

// Import message service features required for subscribing and the message channel
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext, publish
} from "lightning/messageService";
import orderMessage from "@salesforce/messageChannel/orderMessage__c";

export default class OrderProducts extends LightningElement {
    /**
     * Attribute to store order record it
     * @type {string}
     */
    @api recordId;
    /**
     * Attribute to store height of the table
     * @type {integer}
     */
    @api height = 250;

    /**
     * Attribute to store subscription service
     * @type {object}
     */
    subscription = null;

    /**
     * Attribute to store Order by column
     * @type {string}
     */
    sortBy = LABELS.Order_Sort_Column;

    /**
     * Attribute to store Order by column direction
     * @type {string}
     */
    sortDirection = LABELS.Order_Sort_Direction;

    /**
     * Attribute to store list of all orders
     * @type {object}
     */
    lstOrders;

    /**
     * Attribute to show/hide spinner
     * @type {boolean}
     */
    showSpinner = true;

    /**
     * Attribute to store all the custom labels
     * @type {array}
     */
    labels = LABELS;

    /**
     * Attribute to store table column data
     * @type {object}
     */
    lstOrderColumns = COLUMNS;

    /**
     * Attribute to store temporary variable for apex refresh
     * @type {object}
     */
    _orderResponse;

    /**
     * Attribute to show the button if it is active
     * @type {boolean}
     */
    isActivated = true;

    /**
     * Get Message context FROM Message channel
     */
    @wire(MessageContext)
    messageContext;

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

    /**
     * Get the order data from server
     * @param result
     */
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
            showToastNotification(this, LABELS.Error_Title, error.body.message, "Error");
        }
        this.showSpinner = false;
    }

    /**
     * Handle when user clicks on sort
     * @param event
     */
    handleSort(event) {
        this.showSpinner = true;

        if (event.detail.fieldName == 'Name') {
            this.sortBy = 'Product2.Name';
        } else {
            this.sortBy = event.detail.fieldName;
        }
        this.sortDirection = event.detail.sortDirection;
    }

    /**
     * Handle received message from product component
     * @param message
     */
    handleMessage(message) {
        if (message.message.refresh) {
            this.showSpinner = true;
            refreshApex(this._orderResponse);
        }
    }

    /**
     * Handle when user clicks on active button
     * @param event
     */
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
                showToastNotification(this, LABELS.Error_Title, error.body.message, "Error");
                this.showSpinner = false;
            });
    }
}
