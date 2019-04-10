@IsTest
public class SoftwareFeatureRequestTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testUser@software-feature-request.com.test',
            Email = 'testUser@software-feature-request.com',
            ProfileId = standardProfile.Id,
            Alias = 'tusfr',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert testUser;
    }

    @IsTest
    static void testAssignToQueue() {
        User testUser = [SELECT Id FROM User WHERE Name = 'Test User'];
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Unassigned_Software_Feature_Requests' LIMIT 1].Id;

        Software_Feature_Request__c request = new Software_Feature_Request__c(
            Name = 'Test',
            Description__c = 'Test',
            Software_Product__c = 'Identity and Consent Manager',
            Status__c = 'Open'
        );

        Test.startTest();
        System.runAs(testUser){
            insert request;
        }
        Test.stopTest();

        request = [SELECT OwnerId FROM Software_Feature_Request__c WHERE Id = :request.Id];
        
        System.assertEquals(queueId, request.OwnerId, 'It should be assigned to Unassigned Queue');
    }
}
