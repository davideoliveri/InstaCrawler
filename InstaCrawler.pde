/*
/////  InstaCrawler 
/////  A simple instagram search tool
/////  davide oliveri 2014
*/

import java.util.Date;
import java.util.Calendar;

Date photodate;
Calendar rightNow;
Calendar photoTaken;
JSONObject settings;

PImage newImg;
PImage placeholder;
String URLEndpoint = "";
String tagQuery;
String MediaRecent;
String clientID ;
String URLStartpoint = "";
String downloadFolder;
String datapath;
ArrayList<String> IDsaved;
PFont biko;

boolean isSearching = false;
boolean newquery = false;
boolean noError = true;
boolean noFolderSelected;

void setup() {
  settings = loadJSONObject("settings.json");
  tagQuery = settings.getString("default_query");
  clientID = settings.getString("client_id");
  MediaRecent = settings.getString("kind_of_media");
  if (settings.getString("download_folder").length() == 0) { // if the download folder is not specified...
    noFolderSelected = true;
  }
  else {
    noFolderSelected = false;
    downloadFolder = settings.getString("download_folder");
  }
  println("default_query = "+tagQuery);
  URLStartpoint = "https://api.instagram.com/v1/tags/";
  URLEndpoint = URLStartpoint + tagQuery + MediaRecent + clientID;
  println("Our URLEndpoint is = "+URLEndpoint);
  initP5();
  IDsaved = new ArrayList<String>();
  biko = loadFont("Biko-12.vlw");
  datapath = dataPath("");
  frameRate(0.51); // !important we don't want to hit the limit from Instagram so leave it as it is
  rightNow = Calendar.getInstance();
  rightNow.setTimeInMillis(0);
  photoTaken = Calendar.getInstance();
  background(0);
  text("loading...", 10, 15); // I'll use it for a splash screen or I'll move the Pic preview here....
}

void draw() {
  if (frame.isVisible()) {
    frame.setVisible(false); // eliminating the screen, it may come back in the future though...
  }
  while (isSearching) {
    try {
      JSONObject jsoBase = loadJSONObject(URLEndpoint); 
      noError = true; // assuming everything is ok...
      JSONArray jsa = jsoBase.getJSONArray("data");
      //println("There are  "+jsa.size()+" posizioni in \"data\""); // it sould be 20
      for (int i=0; i<jsa.size(); i++) {
        if (!isSearching || newquery) { // check if we have to exit the loop because of a new query
          newquery = false; 
          break;
        }
        JSONObject singleUserData = jsa.getJSONObject(i);
        //println(singleUserData);  //prints the single JSONObject representing the media and user data      
        String imageID = singleUserData.getString("id");
        String createdAt = singleUserData.getString("created_time");
        long dt = (long) parseInt(createdAt)*1000;
        long fromnowon =  (rightNow.getTimeInMillis());
        println("date\t is\t"+dt);
        println("fromnowon\t is\t" +fromnowon);
        photodate = new Date(dt);
        Date dateisnow = new Date(fromnowon);
        photoTaken.setTimeInMillis(dt);
        int year = photoTaken.get(Calendar.YEAR);
        int month = photoTaken.get(Calendar.MONTH);
        int day = photoTaken.get(Calendar.DAY_OF_MONTH);
        int hour = photoTaken.get(Calendar.HOUR_OF_DAY);
        int minute = photoTaken.get(Calendar.MINUTE);
        int second = photoTaken.get(Calendar.SECOND);
        // month +1 because of a bug, I guess. Try to uncomment the line below... 
        //println("month is = "+month);
        String numericalDateTime = nf(year, 4)+nf(month+1, 2)+nf(day, 2)+"_"+nf(hour, 2)+nf(minute, 2)+nf(second, 2);
        println("numerical date & time = "+numericalDateTime);
        println("photodate = "+photodate);
        if (  dt > fromnowon  && !IDsaved.contains(imageID) ) {
          JSONObject allImages = singleUserData.getJSONObject("images");
          JSONObject stdResImg = allImages.getJSONObject("standard_resolution");
          JSONObject usr = singleUserData.getJSONObject("user");
          String usrname = usr.getString("username");
          String URLPhoto = stdResImg.getString("url");
          newImg = loadImage(URLPhoto);
          newImg.save(downloadFolder+numericalDateTime+"_"+usrname+"_"+imageID+".jpg");
          IDsaved.add((imageID));
          println("ADDING new image with ID = "+imageID);
        }
        else {
          println("we already have this, or this media is too old");
          continue;
        }
      }
    }
    catch (Exception e) {
      println("errrrrrr \n"+e+"\n");
      noError = false;
    }
  }
}
