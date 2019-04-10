({
    doInit: function(component, event, helper) {
        component.set('v.columns', [
            { label: 'Title', fieldName: 'Name', type: 'text' },
            { label: 'Software Product', fieldName: 'Software_Product__c', type: 'text' },
            { label: 'Status', fieldName: 'Status__c', type: 'text' }
        ]);

        const userIdAction = component.get('c.getCurrentUserId');
        helper.enqueueServerAction(userIdAction)
            .then($A.getCallback(userId => component.set('v.currentUserId', userId)))
            .catch(error => $A.reportError('Error', error));
        
        const queueIdAction = component.get('c.getUnassignedQueueId');
        helper.enqueueServerAction(queueIdAction)
            .then($A.getCallback(queueId => component.set('v.unassignedQueueId', queueId)))
            .catch(error => $A.reportError('Error', error));

        helper.refreshUserTable(component, event, helper);
        helper.refreshUnassignedTable(component, event, helper);
        helper.subscribe(component, event, helper);
    }
})
