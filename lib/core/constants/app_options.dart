class AppOptions {
  AppOptions._();

  // Blood groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Countries (sample list; extend as needed)
  static const List<String> countries = [
    'Pakistan', 'India', 'Bangladesh', 'United States', 'United Kingdom', 'Saudi Arabia', 'UAE'
  ];

  // Cities by country (sample data; extend as needed)
  static const Map<String, List<String>> citiesByCountry = {
    'Pakistan': ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Peshawar', 'Quetta', 'Multan', 'Faisalabad'],
    'India': ['Mumbai', 'Delhi', 'Bengaluru', 'Chennai', 'Kolkata', 'Hyderabad', 'Pune'],
    'Bangladesh': ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet'],
    'United States': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'San Francisco'],
    'United Kingdom': ['London', 'Birmingham', 'Manchester', 'Leeds', 'Glasgow'],
    'Saudi Arabia': ['Riyadh', 'Jeddah', 'Dammam', 'Mecca', 'Medina'],
    'UAE': ['Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman'],
  };
}
