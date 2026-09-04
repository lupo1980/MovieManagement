
//agentforce
List<String> genres = new List<String>{
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary',
    'Drama', 'Fantasy', 'Horror', 'Mystery', 'Romance', 'Sci-Fi', 'Thriller'
};
List<String> firstWords = new List<String>{
    'Hidden', 'Crimson', 'Silent', 'Electric', 'Golden', 'Forgotten',
    'Midnight', 'Endless', 'Fallen', 'Rising', 'Lost', 'Wandering',
    'Secret', 'Broken', 'Emerald', 'Distant', 'Neon', 'Velvet',
    'Ancient', 'Brave'
};
List<String> secondWords = new List<String>{
    'Horizon', 'Signal', 'Voyage', 'Kingdom', 'Echo', 'Lantern',
    'Compass', 'Harbor', 'Orbit', 'Garden', 'Mountain', 'River',
    'Machine', 'Season', 'Promise', 'Storm', 'Valley', 'Library',
    'Crown', 'Gateway'
};

List<Movie__c> movies = new List<Movie__c>();
for (Integer index = 0; index < 2500; index++) {
    Integer firstIndex = Math.mod(index * 7 + 3, firstWords.size());
    Integer secondIndex = Math.mod(index * 11 + 5, secondWords.size());
    Integer genreIndex = Math.mod(index * 13 + 2, genres.size());
    Integer ratingTenths = 10 + (Integer)(Math.random() * 90);

    movies.add(new Movie__c(
        Name = firstWords[firstIndex] + ' ' + secondWords[secondIndex] + ' ' + (index + 1),
        Genre__c = genres[genreIndex],
        IMDB_Rating__c = ratingTenths / 10.0
    ));
}

insert movies;
System.debug('Inserted ' + movies.size() + ' movie records.');
