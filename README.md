# GroupNav(live_location_tracker)

GroupNav is a mobile app to share your realtime location with GPS tracking and stay connected with your friends, families and co-workers. Hop on in, form some groups and get started. 

The application is built using Flutter with Firebase and Firestore to handle the authentication of users and data management.


## Features
  
  - Live Location Sharing between members of a group using Location Markers on Google Maps.
  - Form multiple groups with your friends or family easily and share your location with each other.
  - Users can login either by creating an account or sign-in using their Google accounts as well.


## How the Location Sharing Works?
  ![image](https://user-images.githubusercontent.com/52448449/126298089-2a105b96-d4c6-4281-9b78-072df0f53524.png)

- The device gets its continous location updates from GPS using the Google Maps API.
- Location data for the user is updated in their respective firestore documents, and subsequently in the group documents.
- Other devices sharing goups with the first user read that firebase firestore document and show the marker in the stored location.

## Contributors
  GroupNav has been designed and developed by
  - [Divyam Singal](https://github.com/div5252)
  - [Utsav Bhardwaj](https://github.com/TenzonUltra)
  - [Shubham Agarwal](https://github.com/shubhamiitg)
