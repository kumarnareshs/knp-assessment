/**
 * Created by Naresh Kumar on 16/08/2021.
 */

//import methods
import {LightningElement, wire, api} from "lwc";
import {showToastNotification} from "c/util";
import {LABELS} from "c/constant";

//import controller
import getAvailableProducts from "@salesforce/apex/AvailableProductsController.getAvailableProducts";
import addOrderItem from "@salesforce/apex/AvailableProductsController.addOrderItem";

const COLUMNS = [
    {
        label: "",
        type: "button-icon",
        initialWidth: 75,
        typeAttributes: {
            iconName: "utility:add",
            title: "Add",
            variant: "border-filled",
            alternativeText: "View"
        }
    },
    {label: "Name", fieldName: "Name", type: "text", sortable: true},
    {
        label: "List Price",
        fieldName: "UnitPrice",
        type: "currency",
        sortable: true
    }
];

// Import message service features required for publishing and the message channel
import {publish, MessageContext} from "lightning/messageService";
import orderMessage from "@salesforce/messageChannel/orderMessage__c";

export default class AvailableProducts extends LightningElement {

    /**
     * Attribute to store height of the table
     * @type {integer}
     */
    @api height = 250;

    /**
     * Attribute to store order record id
     * @type {string}
     */
    @api recordId;

    /**
     * Attribute to store Order by column
     * @type {string}
     */
    sortBy = LABELS.Product_Sort_Column;

    /**
     * Attribute to store Order by column direction
     * @type {string}
     */
    sortDirection = LABELS.Product_Sort_Direction;

    /**
     * Attribute to store search keyword from user
     * @type {string}
     */
    search;

    /**
     * Attribute to store list of all the available products
     * @type {object}
     */
    lstAvailableProducts;

    /**
     * Attribute to show/hide the spinner
     * @type {boolean}
     */
    showSpinner = true;

    /**
     * Attribute to store all the custom labels
     * @type {Array}
     */
    labels = LABELS;

    /**
     * Attribute to store table header data
     * @type {Array}
     */
    lstProductColumns = COLUMNS;

    /**
     * Get Message context FROM Message channel
     */
    @wire(MessageContext)
    messageContext;

    get dataTableStyle() {
        return "height: " + this.height + "px;";
    }

    /**
     * Get the available products
     * @param result
     */
    @wire(getAvailableProducts, {
        sortBy: "$sortBy",
        sortDirection: "$sortDirection"
    })
    wiredAvailableProductsResponse({error, data}) {
        this.showSpinner = true;
        if (data) {
            this.lstAvailableProducts = data;
        } else if (error) {
            showToastNotification(this, LABELS.Error_Title, error.body.message, "Error");
        }
        this.showSpinner = false;
    }

    /**
     * Handle sorting when user sorts in the table
     * @param event
     */
    handleSort(event) {
        this.showSpinner = true;
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    }

    /**
     * Handle search by product name
     * @param event
     */
    handleSearch(event) {
        this.showSpinner = true;
        this.search = event.detail.value;
        getAvailableProducts({
            sortBy: this.sortBy,
            sortDirection: this.sortDirection,
            search: this.search
        })
            .then((result) => {
                if (result) {
                    this.lstAvailableProducts = result;
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                showToastNotification(this, LABELS.Error_Title, error.body.message, "Error");
                this.showSpinner = false;
            });
    }

    /**
     * handle when user try to add product to the cart
     * @param event
     */
    handleRowAction(event) {
        const priceBookEntryId = event.detail.row.Id;
        this.showSpinner = true;
        addOrderItem({
            priceBookEntryId: priceBookEntryId,
            orderRecordId: this.recordId
        })
            .then((result) => {
                if (result) {
                    const payload = {
                        source: "availableProducts",
                        message: {refresh: true}
                    };
                    publish(this.messageContext, orderMessage, payload);
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                showToastNotification(this, LABELS.Error_Title, error.body.message, "Error");
                this.showSpinner = false;
            });
    }
}
