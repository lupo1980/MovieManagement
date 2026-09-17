public with sharing class MovieReviewDelete implements Database.Batchable<sObject>, Schedulable {
  public Database.QueryLocator start(Database.BatchableContext context) {
    String query = 'SELECT Id FROM Movie_Review__c WHERE Review_Status__c = \'Cancelled\'';
    return Database.getQueryLocator(query, AccessLevel.USER_MODE);
  }

  public void execute(SchedulableContext sc) {
    MovieReviewDelete batch = new MovieReviewDelete();
    Id batchProcessId = Database.executeBatch(batch, 200);
  }

  public void execute(Database.BatchableContext context, List<sObject> scope) {
    //delete as user scope;
    //below allow a better security control the access level for the delete operation,
    //besides User mode is the default. we explicity set the access level to User mode
    //to ensure that the delete operation respects the user's permissions.
    Database.DeleteResult[] results = Database.delete(
      scope,
      false,
      AccessLevel.USER_MODE
    );
    Database.emptyRecycleBin(scope);
  }

  public void finish(Database.BatchableContext context) {
  }
}
