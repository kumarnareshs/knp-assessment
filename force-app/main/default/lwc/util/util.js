/**
 * Created by Naresh Kumar on 16/08/2021.
 */

import {ShowToastEvent} from "lightning/platformShowToastEvent";

/**
 * Show the toast notification message in flow header
 * @param instance - this
 * @param title
 * @param message
 * @param variant
 */
 const showToastNotification = (instance, title, message, variant) => {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    instance.dispatchEvent(evt);
}


 export {

    showToastNotification
};