# 🚕 TaxiCab — Premium Ride Service

A production-ready Flutter taxi application with real-time passenger and driver flows, built with Firebase, BLoC state management, and OpenStreetMap.

---

## 📱 Features

### 🧑‍💼 Passenger Flow

| Step | Description |
|------|-------------|
| 1. **Address Selection** | Search pickup and destination using Nominatim OSM autocomplete with 400ms debounce and search history |
| 2. **Tariff Selection** | Choose Economy, Comfort, or Business — price calculated from real OSRM route distance + duration |
| 3. **Order a Ride** | Tap "Заказать поездку" to create an order in Firebase; animated search screen shown |
| 4. **Driver Assigned** | Driver card appears with name, photo, car details, license plate, and rating |
| 5. **Driver Arriving** | Live driver location shown on map; countdown indicator |
| 6. **In Progress** | Trip details overlay with distance, ETA, and fare |
| 7. **Completed** | Interactive 5-star driver rating sheet |
| 8. **History** | Full ride history with status, addresses, price, and date |

### 🚗 Driver Flow

| Step | Description |
|------|-------------|
| 1. **Role Selection** | Choose driver role on first launch |
| 2. **Online Toggle** | Go online/offline with a single switch |
| 3. **Available Orders** | Real-time list of passenger orders, sorted by price (DESC) |
| 4. **Accept Ride** | One-tap accept; ride assigned to driver |
| 5. **Start / Complete** | Tap "Начать поездку" → "Завершить поездку" |
| 6. **Earnings History** | Total earnings summary and ride-by-ride breakdown |

---

## 🏗 Architecture

```
lib/
├── app/
│   └── app.dart                  # Root widget, BLoC/repository providers
├── core/
│   ├── models/
│   │   ├── address_model.dart    # Nominatim address + short name
│   │   ├── driver_model.dart     # Driver profile + car info
│   │   ├── quick_address_model.dart  # Home/Work/Favourite addresses
│   │   ├── ride_model.dart       # Ride lifecycle, tariff, status
│   │   └── user_model.dart       # Passenger/Driver user model
│   ├── services/
│   │   ├── auth_service.dart     # Firebase Auth (anonymous sign-in)
│   │   ├── driver_service.dart   # Driver CRUD, online status, location
│   │   └── ride_service.dart     # Full RideService: search, route, fare, Firebase
│   └── theme/
│       └── app_theme.dart        # Dark premium Material 3 theme
├── features/
│   ├── auth/
│   │   ├── bloc/auth_bloc.dart
│   │   └── pages/role_selection_page.dart
│   ├── passenger/
│   │   ├── bloc/passenger_bloc.dart
│   │   ├── pages/
│   │   │   ├── passenger_home_page.dart
│   │   │   ├── passenger_history_page.dart
│   │   │   └── passenger_profile_page.dart
│   │   └── widgets/
│   │       ├── address_panel.dart
│   │       ├── driver_arriving_card.dart
│   │       ├── driver_found_card.dart
│   │       ├── rating_sheet.dart
│   │       ├── searching_animation.dart
│   │       └── tariff_selector.dart
│   ├── driver/
│   │   ├── bloc/driver_bloc.dart
│   │   ├── pages/
│   │   │   ├── driver_home_page.dart
│   │   │   ├── driver_history_page.dart
│   │   │   └── driver_profile_page.dart
│   │   └── widgets/
│   │       ├── active_ride_card.dart
│   │       ├── available_orders_list.dart
│   │       └── online_toggle.dart
│   └── shared/
│       └── widgets/
│           ├── address_search_field.dart  # Autocomplete with debounce
│           ├── glass_card.dart            # Frosted glass effect
│           ├── star_rating.dart           # Display + interactive rating
│           └── user_avatar.dart           # Avatar with initials fallback
└── main.dart
```

---

## 🔧 Technical Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Material 3) |
| State Management | flutter_bloc 9.x |
| Backend | Firebase (Auth, Firestore) |
| Maps | flutter_map + OpenStreetMap |
| Address Search | Nominatim OSM API |
| Routing | OSRM (Open Source Routing Machine) |
| Location | geolocator |
| Notifications | firebase_messaging |
| Persistence | shared_preferences |

---

## 🎨 Design System

The app uses a **premium dark theme** inspired by high-end ride services:

- **Primary colors**: `#E94560` (gold/red accent) on deep navy `#1A1A2E`
- **Cards**: Subtle `#1E1E2E` surface with `rgba(255,255,255,0.06)` borders
- **Typography**: Material 3 text styles with tight letter-spacing
- **Frosted glass**: `BackdropFilter` blur overlays for premium iOS-style effect
- **Animations**: Scale transitions, pulsing search indicator

---

## 🗺 RideService API

```dart
// Address search (Nominatim OSM, debounced in UI)
Future<List<AddressModel>> searchAddress(String query)

// Route calculation (OSRM)
Future<RouteInfo?> fetchRoute(AddressModel from, AddressModel to)

// Fare calculation
double calculateFare(RouteInfo route, RideTariff tariff)

// Current location
Future<Position?> getCurrentLocation()

// Firebase ride management
Future<RideModel> createRide({...})
Stream<RideModel?> watchRide(String rideId)
Stream<List<RideModel>> watchAvailableRides()
Future<void> acceptRide(String rideId, String driverId)
Future<void> updateRideStatus(String rideId, RideStatus status)
Future<void> cancelRide(String rideId, String reason)
Future<void> rateRide({rideId, isPassenger, rating})

// Quick addresses (Firebase)
Stream<List<QuickAddressModel>> watchQuickAddresses(String userId)
Future<void> addQuickAddress({userId, label, category, address})
Future<void> deleteQuickAddress(String userId, String addressId)

// Search history (local)
Future<void> addToHistory(AddressModel address)
List<AddressModel> get history
```

---

## 📈 Development Roadmap

### v1.1 (Current)
- [x] Full passenger booking flow
- [x] Full driver acceptance flow
- [x] OSM address autocomplete with history
- [x] OSRM route calculation and fare
- [x] Firebase real-time sync
- [x] Premium dark UI

### v1.2 (Planned)
- [ ] Push notifications: driver arriving, trip started, trip completed
- [ ] Phone number auth (SMS OTP)
- [ ] In-app chat between passenger and driver
- [ ] Surge pricing (peak hour multiplier)
- [ ] Driver earnings dashboard with charts

### v1.3 (Future)
- [ ] Scheduled rides
- [ ] Corporate accounts with billing
- [ ] Multi-stop trips
- [ ] Promo codes and referral system
- [ ] Driver document verification

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.10
- Firebase project with Firestore + Auth + Messaging enabled
- Android SDK (for APK build)

### Setup

```bash
flutter pub get
```

Add your `google-services.json` to `android/app/` and `GoogleService-Info.plist` to `ios/Runner/`.

### Run

```bash
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## 🔥 Firebase Firestore Schema

```
users/{uid}
  name: string
  phone: string
  role: "passenger" | "driver"
  rating: number
  ratingCount: number
  photoUrl: string?
  createdAt: timestamp

drivers/{driverId}
  name, phone, photoUrl, rating, ratingCount
  totalRides: number
  isOnline: boolean
  currentLat, currentLon: number?
  currentRideId: string?
  car: { make, model, color, licensePlate, year }

rides/{rideId}
  passengerId: string
  driverId: string?
  pickupAddress: AddressMap
  destinationAddress: AddressMap
  status: searching | driverAssigned | driverArriving | inProgress | completed | cancelled
  tariff: economy | comfort | business
  price: number
  createdAt: timestamp
  completedAt: timestamp?
  passengerRating, driverRating: number?
  cancelReason: string?

users/{uid}/quickAddresses/{id}
  label: string
  category: home | work | favorite
  address: AddressMap
```

---

*Built with ❤️ using Flutter & Firebase*
