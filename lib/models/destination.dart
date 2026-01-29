class Destination {
  final String id;
  final String name;
  final String country;
  final String imageAsset;
  final double rating;
  final String description;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.imageAsset,
    required this.rating,
    required this.description,
  });

  static List<Destination> get mockDestinations => [
        const Destination(
          id: '1',
          name: 'Kyoto',
          country: 'Japan',
          imageAsset: 'assets/destinations/tokyo_japan_1769716499642.png',
          rating: 4.9,
          description:
              'Experience the ancient temples and vibrant seasons of Japan\'s cultural capital.',
        ),
        const Destination(
          id: '2',
          name: 'Santorini',
          country: 'Greece',
          imageAsset: 'assets/destinations/barcelona_spain_1769716482283.png',
          rating: 4.8,
          description:
              'Iconic white buildings, blue domes, and breathtaking sunsets over the Aegean Sea.',
        ),
        const Destination(
          id: '3',
          name: 'Reykjavik',
          country: 'Iceland',
          imageAsset: 'assets/destinations/cape_town_1769716632738.png',
          rating: 4.9,
          description:
              'Land of fire and ice, known for Northern Lights and stunning geothermal landscapes.',
        ),
        const Destination(
          id: '4',
          name: 'Bali',
          country: 'Indonesia',
          imageAsset: 'assets/destinations/maldives_1769716466470.png',
          rating: 4.7,
          description:
              'Tropical paradise featuring lush jungles, serene beaches, and rich spiritual culture.',
        ),
        const Destination(
          id: '5',
          name: 'New York',
          country: 'USA',
          imageAsset: 'assets/destinations/dubai_uae_1769716450383.png',
          rating: 4.8,
          description:
              'The city that never sleeps, offering endless entertainment, dining, and iconic landmarks.',
        ),
        const Destination(
          id: '6',
          name: 'Paris',
          country: 'France',
          imageAsset: 'assets/destinations/paris_france_1769716433408.png',
          rating: 4.9,
          description:
              'The City of Light, home to the Eiffel Tower, world-class art, and romantic ambiance.',
        ),
        const Destination(
          id: '7',
          name: 'Dubai',
          country: 'UAE',
          imageAsset: 'assets/destinations/dubai_uae_1769716450383.png',
          rating: 4.8,
          description:
              'Futuristic metropolis with luxury shopping, ultramodern architecture, and desert adventures.',
        ),
        const Destination(
          id: '8',
          name: 'Maldives',
          country: 'Maldives',
          imageAsset: 'assets/destinations/maldives_1769716466470.png',
          rating: 4.9,
          description:
              'Pristine tropical islands with crystal-clear waters, perfect for diving and relaxation.',
        ),
        const Destination(
          id: '9',
          name: 'Barcelona',
          country: 'Spain',
          imageAsset: 'assets/destinations/barcelona_spain_1769716482283.png',
          rating: 4.8,
          description:
              'Vibrant city featuring Gaudí\'s masterpieces, Mediterranean beaches, and rich culture.',
        ),
        const Destination(
          id: '10',
          name: 'Tokyo',
          country: 'Japan',
          imageAsset: 'assets/destinations/tokyo_japan_1769716499642.png',
          rating: 4.9,
          description:
              'Electric metropolis blending ancient traditions with cutting-edge technology and neon lights.',
        ),
        const Destination(
          id: '11',
          name: 'Rome',
          country: 'Italy',
          imageAsset: 'assets/destinations/rome_italy_1769716525807.png',
          rating: 4.9,
          description:
              'Eternal City filled with ancient ruins, Renaissance art, and incredible Italian cuisine.',
        ),
        const Destination(
          id: '12',
          name: 'London',
          country: 'United Kingdom',
          imageAsset: 'assets/destinations/london_uk_1769716541793.png',
          rating: 4.8,
          description:
              'Historic capital with royal palaces, world-class museums, and diverse cultural scene.',
        ),
        const Destination(
          id: '13',
          name: 'Sydney',
          country: 'Australia',
          imageAsset: 'assets/destinations/sydney_australia_1769716556814.png',
          rating: 4.8,
          description:
              'Harbor city famous for its Opera House, beaches, and laid-back Australian lifestyle.',
        ),
        const Destination(
          id: '14',
          name: 'Machu Picchu',
          country: 'Peru',
          imageAsset: 'assets/destinations/machu_picchu_1769716571641.png',
          rating: 4.9,
          description:
              'Ancient Incan citadel set high in the Andes Mountains, a wonder of the world.',
        ),
        const Destination(
          id: '15',
          name: 'Venice',
          country: 'Italy',
          imageAsset: 'assets/destinations/venice_italy_1769716588510.png',
          rating: 4.8,
          description:
              'Romantic floating city with winding canals, gondolas, and stunning architecture.',
        ),
        const Destination(
          id: '16',
          name: 'Amsterdam',
          country: 'Netherlands',
          imageAsset:
              'assets/destinations/amsterdam_netherlands_1769716615790.png',
          rating: 4.7,
          description:
              'Charming city of canals, bicycles, tulips, and world-renowned museums.',
        ),
        const Destination(
          id: '17',
          name: 'Cape Town',
          country: 'South Africa',
          imageAsset: 'assets/destinations/cape_town_1769716632738.png',
          rating: 4.8,
          description:
              'Stunning coastal city with Table Mountain, diverse wildlife, and vibrant culture.',
        ),
        const Destination(
          id: '18',
          name: 'Rio de Janeiro',
          country: 'Brazil',
          imageAsset: 'assets/destinations/rio_de_janeiro_1769716649280.png',
          rating: 4.8,
          description:
              'Vibrant beach city with Christ the Redeemer, Carnival celebrations, and samba energy.',
        ),
        const Destination(
          id: '19',
          name: 'Singapore',
          country: 'Singapore',
          imageAsset: 'assets/destinations/singapore_1769716664632.png',
          rating: 4.8,
          description:
              'Modern city-state with futuristic gardens, diverse cuisine, and impeccable cleanliness.',
        ),
        const Destination(
          id: '20',
          name: 'Istanbul',
          country: 'Turkey',
          imageAsset: 'assets/destinations/istanbul_turkey_1769716681209.png',
          rating: 4.9,
          description:
              'Historic city bridging Europe and Asia, rich in Ottoman heritage and vibrant bazaars.',
        ),
      ];
}
