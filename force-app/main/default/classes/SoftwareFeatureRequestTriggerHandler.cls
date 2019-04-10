public with sharing class SoftwareFeatureRequestTriggerHandler {
    public static void handleBeforeInsert(List<Software_Feature_Request__c> requests) {
        Id queueId = SoftwareFeatureRequestsController.getUnassignedQueueId();
        for (Software_Feature_Request__c request : requests) {
            request.OwnerId = queueId;
        }
    }

    public static void handleAfterInsert(List<Software_Feature_Request__c> requests) {
        publishNotifications(requests, null);
    }

    public static void handleAfterUpdate(List<Software_Feature_Request__c> newRequests,
            Map<Id, Software_Feature_Request__c> oldRequestsById) {
        List<Software_Feature_Request__c> filteredRequests = new List<Software_Feature_Request__c>();
        for (Software_Feature_Request__c newRequest : newRequests) {
            Software_Feature_Request__c oldRequest = oldRequestsById.get(newRequest.Id);
            if (newRequest.Name != oldRequest.Name || newRequest.OwnerId != oldRequest.OwnerId ||
                    newRequest.Software_Product__c != oldRequest.Software_Product__c ||
                    newRequest.Status__c != oldRequest.Status__c) {
                filteredRequests.add(newRequest);
            }
        }

        if (!filteredRequests.isEmpty()) {
            publishNotifications(filteredRequests, oldRequestsById);
        }
    }

    private static void publishNotifications(List<Software_Feature_Request__c> requests,
            Map<Id, Software_Feature_Request__c> oldRequests) {
        List<Software_Feature_Request__c> requestsWithOwnerName = [
            SELECT OwnerId, Name, Owner.Name
            FROM Software_Feature_Request__c
            WHERE Id IN :requests
        ];
        List<Software_Feature_Request_Notification__e> notifications = new List<Software_Feature_Request_Notification__e>();
        for (Software_Feature_Request__c request : requestsWithOwnerName) {
            Software_Feature_Request_Notification__e notification = new Software_Feature_Request_Notification__e();
            notification.Software_Feature_Request__c = request.Id;
            notification.New_Owner_Id__c = request.OwnerId;
            notification.New_Title__c = request.Name;
            notification.New_Owner_Name__c = request.Owner.Name;

            if (oldRequests != null && oldRequests.containsKey(request.Id)) {
                notification.Old_Owner_Id__c = oldRequests.get(request.Id).OwnerId;
            }

            notifications.add(notification);
        }
        List<Database.SaveResult> results = EventBus.publish(notifications);
    }
}
