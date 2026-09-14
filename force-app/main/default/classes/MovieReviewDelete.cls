public with sharing class MovieReviewDelete implements Database.Batchable<sObject> {
  public final String query;

  public MovieReviewDelete(String queryParam) {
    this.query = queryParam;
  }

  public Database.QueryLocator start(Database.BatchableContext context) {
    return Database.getQueryLocator(this.query, AccessLevel.USER_MODE);
  }

  public void execute(Database.BatchableContext context, List<sObject> scope) {
    delete as user scope;
  }

  public void finish(Database.BatchableContext context) {
  }
}
