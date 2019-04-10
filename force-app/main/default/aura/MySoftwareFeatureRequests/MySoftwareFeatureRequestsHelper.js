({
    refreshUserTable: function(component, event, helper) {
        const myReqsAction = component.get('c.fetchMySoftwareFeatureRequests');
        helper.enqueueServerAction(myReqsAction)
            .then($A.getCallback(requests => component.set('v.myRequests', requests)))
            .catch(error => $A.reportError('Error', error));
    },

    refreshUnassignedTable: function(component, event, helper) {
        const unassignedReqsAction = component.get('c.fetchUnassignedSoftwareFeatureRequests');
        helper.enqueueServerAction(unassignedReqsAction)
            .then($A.getCallback(requests => component.set('v.unassignedRequests', requests)))
            .catch(error => $A.reportError('Error', error));
    },

    enqueueServerAction: function(action) {
        return new Promise($A.getCallback((resolve, reject) => {
            action.setCallback(this, response => {
                const state = response.getState();
                if (state === 'SUCCESS') {
                    resolve(response.getReturnValue());
                } else if (state === 'ERROR') {
                    const errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        reject(Error(errors[0].message));
                    } else {
                        reject(Error('Unknown error'));
                    }
                }
            });
    
            $A.enqueueAction(action);
        }));
    },

    subscribe: function(component, event, helper) {
        const empApi = component.find('empApi');
        empApi.onError($A.getCallback(message => $A.reportError('Error', Error(error))));
        const channel = component.get('v.channel');
        const replayId = -1;
        const showNotification = function(message) {
            const userId = component.get('v.currentUserId');
            const queueId = component.get('v.unassignedQueueId');
            const ownerId = message.data.payload.New_Owner_Id__c;
            if (userId && userId != ownerId && queueId && queueId != ownerId) {
                const title = message.data.payload.New_Title__c;
                const ownerName = message.data.payload.New_Owner_Name__c;
                const notificationMessage = 'Software Feature Request "' + title + '" assigned to ' + ownerName + ' was updated';
                helper.showInfoToast(notificationMessage);
            } else if (userId && userId == ownerId) {
                helper.refreshUserTable(component, event, helper);
            } else if (queueId && queueId == ownerId) {
                helper.refreshUnassignedTable(component, event, helper);
            }
        };
        empApi.subscribe(channel, replayId, $A.getCallback(showNotification))
            .then($A.getCallback(newSubscription => {
                component.set('v.subscription', newSubscription);
                helper.showInfoToast('Subscribed to Software Feature Request notifications');
            }));
    },

    showInfoToast: function(message) {
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({ type: 'info', message: message });
        toastEvent.fire();
    }
})
