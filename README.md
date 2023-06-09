# ARvis #

ARvis is an Augmented Reality mobile application that uses image recognition technology to recognize the movie from the image of its poster and then displays the movie trailer along with other helpful information about the movie. Simply pointing the smartphone camera at a movie poster will enable users to use this application that will quickly and accurately identify the title of the film and show the trailer. The application also provides additional information such as the main lead, genre, IMDB rating, available languages, and worldwide collection, making it a comprehensive tool for movie discovery.

![Screenshot](arvis1.png)

![Screenshot](arvis2.png)

![Screenshot](arvis3.png)

## Introduction ##

With applications in a variety of fields, including education, gaming, retail, and entertainment, Augmented Reality (AR) technology has been gaining popularity quickly in recent years. In the entertainment sector, AR has grown in popularity as a way to improve audience's movie-watching experiences. The goal of this project is to use AR technology to offer a unique and immersive experience for users to interact with movie posters and learn about new movies.

Through the use of AR technology, the application provides users with an innovative and entertaining way to interact with movie posters, allowing them to fully immerse themselves in the movie experience and discover new films in an enjoyable and interesting way.

## Theoretical Background ##

ARvis is developed using the Swift programming language, a native language designed by Apple that is used to develop applications for iOS. Swift libraries such as ARKit, XCDYoutubeKit, SpriteKit, SwiftyJSON are effectively used in order to process different types of data from API’s at various levels of the application accordingly.

The following APIs are used to build this project:

### ARKit ###

Apple's Software Development Kit (SDK) called ARKit enables programmers to create Augmented Reality (AR) applications for iOS devices. The ability to track the user's position and orientation in the real world, identify planes and other surfaces, and add 3D objects to the environment are all made possible by the tools and APIs that are provided by ARKit. With ARKit, developers can produce intensely immersive and interactive AR experiences that improve users' perceptions of their surroundings.

### Google Cloud Vision API ###

The robust machine learning-based image analysis tool known as Google Vision API enables programmers to add cutting-edge image recognition capabilities to their applications The API can be used to analyse facial expressions, recognize logos, and perform web detection in addition to finding objects, text, and other information inside images.

### Google YouTube Data API V3 ###

The Google YouTube Data API v3 allows developers to connect with YouTube videos and channels data in their applications. Developers can use this API to access details about certain YouTube videos, including video content like comments, captions, and ratings as well as metadata like title, description, tags, and view count. Developers may create effective video-based applications because to the API's access to channel data, including playlists, subscriptions, and channel information.

### XCDYouTubeKit ###

A third-party framework called XCDYouTubeKit gives iOS app developers a simple way to incorporate YouTube video playback into their applications. It gives developers access to an API that enables them to download video information and stream content directly from YouTube servers. It is therefore a useful tool for developing apps that need YouTube video playback, like the augmented reality application covered in this report.

### IMDB API ###

A third-party API called the IMDb-API enables programmers to access the comprehensive database of movies and TV shows maintained by IMDb. Access to a multitude of data, including title, year, narrative, cast, crew, ratings, and more, is made possible by the API. With this knowledge, developers can create effective applications that let users get detailed information about their favourite films and TV shows as well as discover new films and TV shows

## Implementation ##

![Screenshot](arvis4.png)


ARvis is developed using Swift programming language, a native language designed by Apple which is used to develop applications for iOS. Swift libraries such as ARKit, XCDYoutubeKit, SpriteKit, SwiftyJSON are effectively used in order to process different types of data from API’s at various levels of the application accordingly.

## Experiment and Results ##

### Experiment ###

A total of 15 movie posters of different genres and languages have been considered to study the accuracy and efficiency of the application. For every movie, results specifying whether each API was able to fetch the details of the movie correctly or not is noted which is then analyzed to determine the areas of improvement. The movies selected for the experiment are divided into three sections based on their popularity i.e. Popular, Average, and Unpopular.

### Results ###

| Movie                      | Google Cloud Vision | Google YouTube Data API v3 | IMDB-API |
|----------------------------|---------------------|-----------------------------|----------|
| Spider-Man: No Way Home    | Yes                 | Yes                         | No       |
| Inception                  | Yes                 | Yes                         | Yes      |
| Avatar                     | Yes                 | No                          | No       |
| Baahubali – The Beginning | Yes                 | Yes                         | Yes      |
| KGF – Chapter 2            | Yes                 | Yes                         | Yes      |
| The Vault                  | Yes                 | Yes                         | Yes      |
| The Tomorrow War           | Yes                 | Yes                         | Yes      |
| Venom                      | Yes                 | Yes                         | Yes      |
| Sooryavanshi               | Yes                 | Yes                         | No       |
| The Assistant              | Yes                 | No                          | No       |
| Annihilation               | Yes                 | No                          | Yes      |
| Maanagaram                 | No                  | Yes                         | No       |
| October                    | No                  | No                          | No       |
| Mirage                     | Yes                 | Yes                         | Yes      |
| The Wandering Earth        | Yes                 | Yes                         | No       |


Noting down the success rate of the API’s for a particular category, such as the popularity of the movie, is useful to further analyze and improve the algorithms of the application. Tuning these APIs would definitely improve the efficiency and accuracy of the application.

## Run the Project ##

To run the project, follow the steps below:

1. Unzip the File "22310117".

2. Open X-Code.

3. On the starting window of X-code, select "Open a Project or File" and navigate to the unzipped project folder. Click on open.

4. In X-code, navigate to ARvis/Resources/ and open Keys.plist. Add in the API keys for Google Cloud Vision API, YouTube Data API v3, and IMDB API. Currently, we have added our free API keys, which have a limited number of allowed API calls since it is free.

Note: API Keys can be obtained by registering in the following links:

 - Google Cloud Vision API - https://cloud.google.com/vision
 - Google YouTube Data v3 API - https://developers.google.com/youtube/v3
 - IMDB API - https://imdb-api.com/

5. Connect an iPhone that supports at least iOS 13 and run the app.
