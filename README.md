# ios-swift-iWeather
A weather app developed with Swift language and available on the Apple Store

For making this app works on your computer, we need to: 

Create a swift file called Secret or whatever you like. 
Inside your new file, add three public constants which can be accessible by all your application. 

public let openWeatherAPIKey = YOUR_OPEN_WEATHER_API_KEY &nbsp;
public let FIREBASE_URL_AUTH = YOUR_FIREBASE_AUTH_URL &nbsp;
public let FIREBASE_URL_REQUEST = YOUR_FIREBASE_URL_LINK_TO_CITIES_INFO &nbsp;

As you can see, you need to register an API KEY on http://openweathermap.org/ website, then create a database for your cities on https://www.firebase.com/ . Create a database and add a table cities and upload the city.list.json.gz file which can be downloaded on openweathermap.org website : http://bulk.openweathermap.org/sample/ . Once you have uploaded your json file into your firebase database, provide the link to your table in the FIREBASE_URL_REQUEST constant. (eg: "https://my-app.firebaseio.com/cities")

For iWeather app, user do not need to create an account to use it, however when the app lauch, a request is sent to firebase database to anonymously authenticate the user.
For allowing such kind of authentication, we need to go to the "Login & Auth" section of your firebase dashboard, then click on "Anonymous" tab on check on "Enable Anonymous User Authentication." The Url to provide in FIREBASE_URL_AUTH is the url to your firebase app. (eg: "https://my-app.firebaseio.com")
