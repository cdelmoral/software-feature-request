trigger SoftwareFeatureRequestTrigger on Software_Feature_Request__c (before insert, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            SoftwareFeatureRequestTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SoftwareFeatureRequestTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            SoftwareFeatureRequestTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}