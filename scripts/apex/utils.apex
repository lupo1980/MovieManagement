// movie review PS assignment to my user
    PermissionSetAssignment assignment = new PermissionSetAssignment();
    assignment.AssigneeId = UserInfo.getUserId();
    assignment.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Movie_Full_Access' LIMIT 1].Id;

    insert assignment;