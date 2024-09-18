enum FoursquareCategories {
  favorites("Favorites", "1"),
  arts("Arts and Entertainment", "10000"),
  restaurant("Dining and Drinking", "13000"),
  events("Events", "14000"),
  landmarks("Landmarks", "16000"),
  stores("Stores", "17000"),
  sports("Sports", "18000"),
  travel("Travel", "19000");

  const FoursquareCategories(this.name, this.id);

  final String name;
  final String id;
}
