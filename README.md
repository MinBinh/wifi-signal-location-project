# Wi-Fi-Signal Location Project

This is a school machine learning project I made as a way for students to check in their location in school during a period we call Flex Block. Of course this project would not work after downloading as data and variables relating to my school an API key for Google, to record data into a spreadsheet, have been removed. 

This project have two parts:
- Creating the model (flies in `\lib` that aren't in folder called app)
- Creating the app (flies in `\lib\app`)

This is just a brief documentation of my project's process, and the following is an explanation of each the folders and files within this project.

### Wi-Fi-Signal Location Prediction Model

Using Wi-Fi signals to predict one's location is not a new concept and the simple gist is collecting the different signals a phone detects within a pre-defined area and using that data to create a model through a machine learning algorithm. 

In this case, I chose to make a model using the k-Nearest-Neighbour algorithm and so chose to asign collected data labels of the area they are collected (like Room 3005 for example). This process is done through running the files `collecting_data.dart` and `collecting_test.dart` for training and testing data respectively which outputs strings of JSON data in which I copied into a JSON file. This is possible from using the dart libraries wifi_hunter and network_info_plus.

Afterward, data is then funneled into `ModelForWifiLocation.ipynb` where a Data is normalised and then used for creating the Wi-Fi location model using KNN with parameter 19 neighbours. This should output a json file `wififlex.json` which would be then be put into the `\assets` folder to acess the model later.

`model_testing.dart` is just a file to test the model's prediction of the location of a student within my school.

Model accurary seems to be around 88% but these analysing these errors revealed that model is only wrongly predicting rooms adjacent to target room. This would put the model at an accurary possibly closer to 100%.

_Note: To reiterate again, the wifi-signals use to train the model is from my school and therefore will not work outside._

### App

After creating the model, an app is created for implementation in the school.

A big button displays model prediction while smaller bottom buttons are present to offer students other options if the model predicts the incorrect adjacent area within the school.

In additional app also ask student if they are meeting with a teacher in the room. 

Finally, data of the model's prediction, the students final actual location, time, and teacher they met (if they did) are sent to a spreadsheet using Google Sheet API and Gsheets library of Dart.
