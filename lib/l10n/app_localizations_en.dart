// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get language => 'Language';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get idDocument => 'ID Document';

  @override
  String get viewDocument => 'View Document';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get changePassword => 'Change Password';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get hosting => 'Hosting';

  @override
  String get bookingRequests => 'Booking Requests';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get support => 'Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get verified => 'Verified';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String get notProvided => 'Not provided';

  @override
  String get privacyPolicyComingSoon => 'Privacy policy coming soon!';

  @override
  String get termsOfServiceComingSoon => 'Terms of Service coming soon!';

  @override
  String get appDescription =>
      'Find your perfect home with Maisonel - the premier home rental platform.';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get validPhoneStart09 => 'Please enter a valid number start with 09';

  @override
  String get validPhone => 'Please enter a valid phone number';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinMaisonel => 'Join Maisonel today';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get birthdate => 'Birthdate';

  @override
  String get selectBirthdate => 'Select your birthdate';

  @override
  String get pleaseSelectBirthdate => 'Please select your birthdate';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get reEnterPassword => 'Re-enter your password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get idPhoto => 'ID Photo';

  @override
  String get tapToUploadId => 'Tap to upload ID photo';

  @override
  String get agreeTo => 'I agree to the ';

  @override
  String get acceptTerms => 'Please accept the terms and conditions';

  @override
  String get selectProfilePicture => 'Please select a profile picture';

  @override
  String get uploadIdPhoto => 'Please upload your ID photo';

  @override
  String get accountCreated => 'Account created successfully! Please login.';

  @override
  String get required => 'Required';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get myListings => 'My Listings';

  @override
  String get orders => 'Orders';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get guest => 'Guest';

  @override
  String get findDreamHome => 'Find your dream home';

  @override
  String get featured => 'Featured';

  @override
  String get popularProperties => 'Popular Properties';

  @override
  String get retry => 'Retry';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get noPropertiesFound => 'No properties found';

  @override
  String get checkBackLater =>
      'Check back later for new listings or refresh the page';

  @override
  String get searchProperties => 'Search Properties';

  @override
  String get searchHint => 'Search properties...';

  @override
  String get location => 'Location';

  @override
  String get priceRange => 'Price Range';

  @override
  String get propertyType => 'Property Type';

  @override
  String get bedrooms => 'Bedrooms';

  @override
  String get bathrooms => 'Bathrooms';

  @override
  String get sortBy => 'Sort By';

  @override
  String resultsFound(int count) {
    return 'Results Found: $count';
  }

  @override
  String get noPropertiesMatch => 'No properties match your filters';

  @override
  String get clear => 'Clear';

  @override
  String get searching => 'Searching...';

  @override
  String get any => 'Any';

  @override
  String get all => 'All';

  @override
  String get apartment => 'Apartment';

  @override
  String get house => 'House';

  @override
  String get villa => 'Villa';

  @override
  String get studio => 'Studio';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get rating => 'Rating';

  @override
  String get newest => 'Newest';

  @override
  String get failedToUpdateFavorite => 'Failed to update favorite';

  @override
  String get perMonth => '/ month';

  @override
  String bedroomsCount(int count) {
    return '$count Bed';
  }

  @override
  String bathroomsCount(int count) {
    return '$count Bath';
  }

  @override
  String areaSqm(double area) {
    final intl.NumberFormat areaNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String areaString = areaNumberFormat.format(area);

    return '$areaString m²';
  }

  @override
  String get descriptionTitle => 'Description';

  @override
  String get amenities => 'Amenities';

  @override
  String get bookNow => 'Book Now';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get deletePhotoConfirm =>
      'Are you sure you want to delete this photo?';

  @override
  String get delete => 'Delete';

  @override
  String get addPhotoRequired => 'Please add at least one photo';

  @override
  String get listingPublished => 'Listing published successfully!';

  @override
  String get listingUpdated => 'Listing updated successfully!';

  @override
  String get addNewListing => 'Add New Listing';

  @override
  String get editListing => 'Edit Listing';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get pricePerNight => 'Price per night';

  @override
  String get selectType => 'Select Type';

  @override
  String get locationAddress => 'Location / Address';

  @override
  String get city => 'City';

  @override
  String get sizeSqm => 'Size (sqm)';

  @override
  String get addAmenityHint => 'Add amenity (comma separated)';

  @override
  String get add => 'Add';

  @override
  String get photos => 'Photos';

  @override
  String get publishListing => 'Publish Listing';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get loft => 'Loft';

  @override
  String get addListing => 'Add Listing';

  @override
  String get rejected => 'Rejected';

  @override
  String get notApprovedYet => 'Not Approved Yet';

  @override
  String viewsCount(int count) {
    return '$count views';
  }

  @override
  String get deleteListing => 'Delete Listing';

  @override
  String deleteListingConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get noListingsYet => 'No listings yet';

  @override
  String get startAddingProperties =>
      'Start adding your properties to reach customers';

  @override
  String get bookApartment => 'Book Apartment';

  @override
  String get daily => 'Daily';

  @override
  String get monthly => 'Monthly';

  @override
  String get selectDuration => 'Select Duration';

  @override
  String get selectDates => 'Select Dates';

  @override
  String get startDate => 'Start Date';

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get monthsDurationLabel => 'Duration (Months)';

  @override
  String get rate => 'Rate';

  @override
  String get perMonthSuffix => '/mo';

  @override
  String get perDaySuffix => '/day';

  @override
  String get duration => 'Duration';

  @override
  String monthsCount(int count) {
    return '$count months';
  }

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get total => 'Total';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String bookingFailed(String error) {
    return 'Booking failed: $error';
  }

  @override
  String get bookingSuccess => 'Booking request sent successfully!';

  @override
  String get processingApproval => 'Processing approval...';

  @override
  String get processingRejection => 'Processing rejection...';

  @override
  String get failedToLoadRequests => 'Failed to load requests';

  @override
  String get unknownProperty => 'Unknown Property';

  @override
  String get checkIn => 'Check-in';

  @override
  String get checkOut => 'Check-out';

  @override
  String get nights => 'Nights';

  @override
  String nightsCount(int count) {
    return '$count nights';
  }

  @override
  String get guestLabel => 'Guests';

  @override
  String guestCount(int count) {
    return '$count guests';
  }

  @override
  String get payment => 'Payment';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get bookedOn => 'Booked on';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get noPendingRequests => 'No pending requests found';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get orderHistory => 'Order History';

  @override
  String orderDetails(String id) {
    return 'Order Details #$id';
  }

  @override
  String get propertyLabel => 'Property';

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get status => 'Status';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get leaveReview => 'Leave a Review';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get cancellationRequestSent => 'Cancellation request sent';

  @override
  String noOrdersFoundForStatus(String status) {
    return 'No orders found for $status';
  }

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get selectRating => 'Please select a rating';

  @override
  String get reviewSubmitted => 'Review submitted successfully!';

  @override
  String reviewFailed(String error) {
    return 'Failed to submit review: $error';
  }

  @override
  String get howWasStay => 'How was your stay?';

  @override
  String get shareExperience => 'Share your experience...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String failedToLoadFavorites(String error) {
    return 'Failed to load favorites: $error';
  }

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get startAddingFavorites =>
      'Start adding properties to your favorites!';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enterCurrentPassword => 'Please enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Please enter a new password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get confirmNewPasswordHint => 'Please confirm your new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordChangedSuccess => 'Password changed successfully!';
}
