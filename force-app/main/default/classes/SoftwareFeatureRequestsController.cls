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

    /**
     * Retrieves Software Feature Request records from database for a given Owner Id. The maximum number of records
     * that can be retrieved with the current implementation is 10,000 since the maximum expected number of records
     * for a given Owner is exptected to be in the order of 1,000s. If this limit needs to be higher it would be better
     * to implement some kind of pagination or infinite lazy loading.
     */
    public static List<Software_Feature_Request__c> fetchSoftwareFeatureRequests(Id ownerId) {
        return [
            SELECT Name, Software_Product__c, Status__c
            FROM Software_Feature_Request__c
            WHERE OwnerId = :ownerId
            LIMIT 10000
        ];
    }
}