// movie review PS assignment to my user
    PermissionSetAssignment assignment = new PermissionSetAssignment();
    assignment.AssigneeId = UserInfo.getUserId();
    assignment.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Movie_Full_Access' LIMIT 1].Id;

    insert assignment;


// delete many movie reviews with status cancelled
    //String query = 'SELECT Id FROM Movie_Review__c WHERE Review_Status__c = \'Cancelled\'';
    //String query = 'SELECT Id FROM Movie__c  limit 500';
    
    MovieReviewDelete batch = new MovieReviewDelete();
    Database.executeBatch(batch, 200);    