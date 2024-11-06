import 'package:flutter/material.dart';

void main() {
  runApp(DoctorFinderApp());
}

class DoctorFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Finder',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<String> sliderImages = [
    'https://via.placeholder.com/350x150?text=Looking+for+Specialist+Doctors?',
    'https://via.placeholder.com/350x150?text=Schedule+an+Appointment+Today!',
    'https://via.placeholder.com/350x150?text=Get+Professional+Help+Now!'
  ];

  bool seeAllCategories = false;
  final List<String> categories = [
    'Dentistry', 'Cardiology', 'Pulmonology', 'General',
    'Neurology', 'Gastroenterology', 'Laboratory', 'Vaccination',
    'Dermatology', 'Pediatrics', 'Orthopedics', 'Ophthalmology',
  ];

  final List<Map<String, String>> nearbyClinics = [
    {
      'name': 'Sunrise Health Clinic',
      'rating': '5.0',
      'reviews': '150 Reviews',
      'distance': '2.5 km',
      'address': 'Seattle, WA 98056',
      'location': 'Seattle, USA'
    },
    {
      'name': 'Golden Cardiology',
      'rating': '4.9',
      'reviews': '100 Reviews',
      'distance': '2.3 km',
      'address': 'Bridge St, Seattle, WA',
      'location': 'NY, USA'
    },
  ];

  final List<Map<String, String>> doctors = [
    {'name': 'Dr. David Patel', 'specialty': 'Cardiologist', 'rating': '4.8', 'reviews': '1372 Reviews', 'location': 'Seattle, USA', 'clinicName': 'Sunrise Health Clinic', 'category': 'Cardiology'},
    {'name': 'Dr. Jessica Turner', 'specialty': 'Gynecologist', 'rating': '4.9', 'reviews': '122 Reviews', 'location': 'Seattle, USA', 'clinicName': 'Sunrise Health Clinic', 'category': 'General'},
    {'name': 'Dr. Michael Johnson', 'specialty': 'Orthopedic Surgeon', 'rating': '4.7', 'reviews': '523 Reviews', 'location': 'NY, USA', 'clinicName': 'Golden Cardiology', 'category': 'Orthopedics'},
    {'name': 'Dr. Emily Walker', 'specialty': 'Pediatrician', 'rating': '4.5', 'reviews': '406 Reviews', 'location': 'Seattle, USA', 'clinicName': 'Sunrise Health Clinic', 'category': 'Pediatrics'},
  ];

  String selectedLocation = '';
  List<Map<String, String>> filteredDoctors = [];
  String searchQuery = '';
  String selectedClinic = 'Sunrise Health Clinic';
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _filterDoctors();
  }

  void _filterDoctors() {
    print('Selected categories: $selectedCategories');
    filteredDoctors = doctors.where((doctor) {
      return doctor['clinicName'] == selectedClinic &&
          (doctor['name']!.toLowerCase().contains(searchQuery.toLowerCase()) || searchQuery.isEmpty) &&
          (selectedCategories.isEmpty || selectedCategories.contains(doctor['category']));
    }).toList();
  }

  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      _filterDoctors();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildLocationAndSearch(),
          _buildImageSlider(),
          _buildCategories(),
          _buildNearbyClinics(),
          _buildDoctorsList(),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: selectedLocation),
            decoration: InputDecoration(
              hintText: 'Select location...',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            readOnly: true,
            onTap: () {
              _showLocationDialog();
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_drop_down),
          onPressed: () {
            _showLocationDialog();
          },
        ),
      ],
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Location"),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              children: nearbyClinics.map((clinic) {
                return ListTile(
                  title: Text(clinic['name']!),
                  subtitle: Text(clinic['location']!),
                  onTap: () {
                    setState(() {
                      selectedLocation = clinic['location']!;
                      selectedClinic = clinic['name']!;
                      _filterDoctors();
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Search by Name Component
  Widget _buildSearchByName() {
    return TextField(
      onChanged: _updateSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search doctor...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Category Selection Component
  Widget _buildCategories() {
    final int maxItemsVisible = 8; // Maximum items visible at once
    final List<String> visibleCategories = seeAllCategories
        ? categories
        : categories.take(maxItemsVisible).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Categories", style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  setState(() {
                    seeAllCategories = !seeAllCategories;
                  });
                },
                child: Text(
                  seeAllCategories ? "See Less" : "See All",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: visibleCategories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 categories per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final category = visibleCategories[index];
              final isSelected = selectedCategories.contains(category);

              return GestureDetector(
                onTap: () {
                  _toggleCategory(category);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.medical_services, color: isSelected ? Colors.white : Colors.black),
                      ),
                      SizedBox(height: 5),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
      _filterDoctors();
    });
  }

  Widget _buildLocationAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildLocationSelector(),
          SizedBox(height: 16),
          _buildSearchByName(),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              itemCount: sliderImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(sliderImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                sliderImages.length,
                    (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: _currentPage == index ? 30 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyClinics() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nearby Medical Centers", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nearbyClinics.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 180,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Image.network('https://via.placeholder.com/150', fit: BoxFit.cover)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nearbyClinics[index]['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(nearbyClinics[index]['address']!),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    _buildStarRating(double.parse(nearbyClinics[index]['rating']!)),
                                    SizedBox(width: 5),
                                    Text(nearbyClinics[index]['rating']!),
                                  ],
                                ),
                                Text(nearbyClinics[index]['reviews']!, style: TextStyle(fontSize: 12)),
                                SizedBox(height: 5),
                                Text(nearbyClinics[index]['distance']!, style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${filteredDoctors.length} found', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredDoctors.length,
            itemBuilder: (context, index) {
              final doctor = filteredDoctors[index];
              return ListTile(
                leading: CircleAvatar(radius: 30, backgroundColor: Colors.grey[300], child: Icon(Icons.person)),
                title: Text(doctor['name']!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor['specialty']!),
                    Row(
                      children: [
                        _buildStarRating(double.parse(doctor['rating']!)),
                        SizedBox(width: 5),
                        Text(doctor['rating']!),
                      ],
                    ),
                    Text(doctor['reviews']!, style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.yellow[700],
          size: 16,
        );
      }),
    );
  }
}