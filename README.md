# GroupNav(live_location_tracker)

GroupNav is a mobile app to share your realtime location with GPS tracking and stay connected with your friends, families and co-workers. Hop on in, form some groups and get started. 

The application is built using Flutter with Firebase and Firestore to handle the authentication of users and data management.


## Features
  
  - Live Location Sharing between members of a group using Location Markers on Google Maps.
  
    <img src="https://user-images.githubusercontent.com/75876271/126334045-ff9f6d82-a3a1-4097-931e-2ee2aa2f765d.png" width="240" height="500">
  
  - Form multiple groups with your friends or family easily and share your location with each other.
  
    <img src="https://user-images.githubusercontent.com/75876271/126331434-df6f6bd0-1636-4782-9829-657532733223.png" width="240" height="500">
    
  - Users can login either by creating an account or sign-in using their Google accounts as well.
 
    <img src="https://user-images.githubusercontent.com/75876271/126329267-a50349b1-318a-47a9-a3a9-6319bfd64e02.png" width="240" height="500">


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
