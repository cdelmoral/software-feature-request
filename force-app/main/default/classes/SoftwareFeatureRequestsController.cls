public with sharing class SoftwareFeatureRequestsController {

    @AuraEnabled
    public static List<Software_Feature_Request__c> fetchMySoftwareFeatureRequests() {
        return fetchSoftwareFeatureRequests((Id) UserInfo.getUserId());
    }
    
    @AuraEnabled
    public static List<Software_Feature_Request__c> fetchUnassignedSoftwareFeatureRequests() {
        Id unassignedQueueId = getUnassignedQueueId();
        return SoftwareFeatureRequestsController.fetchSoftwareFeatureRequests(unassignedQueueId);
    }

    @AuraEnabled
    public static Id getCurrentUserId(){
        return (Id) UserInfo.getUserId();
    }

    @AuraEnabled
    public static Id getUnassignedQueueId() {
        return [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Unassigned_Software_Feature_Requests' LIMIT 1].Id;
    }

    public static List<Software_Feature_Request__c> fetchSoftwareFeatureRequests(Id ownerId) {
        return [
            SELECT Name, Software_Product__c, Status__c
            FROM Software_Feature_Request__c
            WHERE OwnerId = :ownerId
            LIMIT 10000
        ];
    }
}