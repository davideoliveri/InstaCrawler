import controlP5.*;
import java.awt.Frame;

ControlFrame cf;
ControlP5 cp5;
ControlFont cp5Font;

color cActive = color(200, 25, 10), cBack = color(100, 70, 200);
boolean freshPhotos = false;

void initP5() {
  cf = addControlFrame("InstaCrawler", 400, 690);
}

ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100); // this can be removed
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

String state;

public class ControlFrame extends PApplet {
  ControlP5 cp5;
  Object parent;
  int w, h;
  int backCol = #54A8BC; 
  int textCol = #3c3c3c;

  void selectFirstTimeFolder(File selection) {
    if (selection == null) {
      println("selection is still null");
      state = "Please Select a folder...";
      cp5.getController("selectdownloadfolder").update();
    }
    else {
      state = "Next tag query is:\n"+tagQuery;
      println("saving in folder: "+selection.getAbsolutePath());
      settings.setString("download_folder", selection.getAbsolutePath()+"/");
      downloadFolder = selection.getAbsolutePath()+"/";
      saveJSONObject(settings, datapath+"/settings.json");
    }
  }

  public void setup() {
    size(w, h);
    frameRate(25);
    textSize(25);
    if (noFolderSelected) {
      selectFolder("Choose a download directory...", "selectFirstTimeFolder");
    }
    state = "Next tag query is:\n"+tagQuery;
    cp5 = new ControlP5(this);
    cp5Font = new ControlFont(biko, 12);
    cp5.setFont(cp5Font);
    cp5.setColorActive(cActive);
    cp5.setColorBackground(cBack);
    cp5.setColorForeground(cBack);
    placeholder = loadImage(datapath+"/placeholder.png");

    PFont font = loadFont(datapath+"/Biko-15.vlw");
    PFont bigfont = loadFont(datapath+"/Biko-24.vlw");
    PFont smallFont = loadFont(datapath+"/Biko-10.vlw");
    cp5.setFont(font);

    cp5.addTextfield("query")
      .setPosition(20, 10)
        .setSize(200, 40)
          .setFocus(true)
            .setFont(bigfont)
              .setAutoClear(true)
                .setColor(color(255))
                  .setColorBackground(#2A555F)
                    .setText(tagQuery);

    cp5.addBang("search")
      .setPosition(240, 10)
        .setSize(80, 40)
          .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    cp5.addBang("settings")
      .setPosition(340, 10)
        .setSize(40, 40)
          .setImage(loadImage(datapath+"/settingsicon.png"))
            .setCaptionLabel("S").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    cp5.addBang("opendownloadfolder")
      .setPosition(340, 70)
        .setSize(40, 40)
          .setImage(loadImage(datapath+"/openfolder.png"))
            .setCaptionLabel("O").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    cp5.addBang("selectdownloadfolder")
      .setPosition(340, 120)
        .setSize(40, 40)
          .setImage(loadImage(datapath+"/downloadfoldersel.png"))
            .setCaptionLabel("I").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    cp5.addBang("alltimePhotos")
      .setPosition(20, 210)
        .setSize(170, 60)
          .setCaptionLabel("All the Photos")
            .setColorForeground(cActive)
              .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    cp5.addBang("timeIsNow")
      .setPosition(210, 210)
        .setSize(170, 60)
          .setCaptionLabel("Fresh Photos")
            .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    // Register Tooltips
    cp5.getTooltip().setDelay(200)    
      .setColorBackground(color(0, 200))
        .setColorLabel(color(255))
          .getLabel().setFont(smallFont);

    cp5.getTooltip().register("settings", "Open the JSON settings file");
    cp5.getTooltip().register("opendownloadfolder", "Open the download folder");
    cp5.getTooltip().register("selectdownloadfolder", "Select the download folder");
  }

  // uhm, I don't like so much this approach but it's still the fastest way to go
  void switchTime() {
    println("freshPhotos = "+freshPhotos);
    cp5.controller("timeIsNow").setColorForeground((freshPhotos==false) ? cBack:cActive);
    cp5.controller("alltimePhotos").setColorForeground((freshPhotos==true) ? cBack:cActive);
  }

  void timeIsNow() {
    freshPhotos = true;
    rightNow = Calendar.getInstance();
    switchTime();
  }

  void alltimePhotos() {
    freshPhotos = false;
    rightNow.setTimeInMillis(0);
    switchTime();
  }

  void query(String theTag) {
    if (theTag.length() > 0 && !theTag.contains(" ")) {
      tagQuery = theTag;
      settings.setString("default_query", tagQuery);
      saveJSONObject(settings, datapath+"/settings.json");
      URLEndpoint = URLStartpoint + tagQuery + MediaRecent + clientID;

      if (isSearching) {
        state = "Searching for \n#"+tagQuery;
      }
      else {
        state = "Next tag query is:\n"+tagQuery;
      }
    }
    else {
      state = "Please provide a tag"; // there's room fro improvement here!
    }
  }

  void search() {
    isSearching = !isSearching;
    if (isSearching) {
      state = "Searching for \n#"+tagQuery;
    }
    else {
      state = "Next tag query is:\n"+tagQuery;
    }
    URLEndpoint = URLStartpoint + tagQuery + MediaRecent + clientID;
    println("are we searching? "+isSearching);
    cp5.controller("search").setCaptionLabel((isSearching==true) ? "stop":"search");
    cp5.controller("search").setColorForeground((isSearching==true) ? cActive:cBack);
  }

  void settings() {
    open(datapath+"/settings.json");
  }

  void opendownloadfolder() {
    open(settings.getString("download_folder"));
  }

  void selectdownloadfolder() {
    selectFolder("Select a download folder...", "folderSelected");
  }

  void folderSelected(File selection) {
    if (selection == null) {
      print("no folder selected");
      cp5.getController("selectdownloadfolder").update();
    }
    else {
      state = "Next tag query is:\n"+tagQuery;
      settings.setString("download_folder", selection.getAbsolutePath()+"/");
      downloadFolder = selection.getAbsolutePath()+"/";
      saveJSONObject(settings, datapath+"/settings.json");
    }
  }

  void controlEvent(ControlEvent theEvent) {      
    if (theEvent.isFrom("query")) {
      Textfield t = (Textfield)theEvent.getController();
      println(t.stringValue()+" from "+t.getName());
      if (t.stringValue().length() != 0) {
        newquery = true;
        if (!isSearching) {
          search(); // toggle isSearching (from search() and start searching - as usual
        }
        else {
          // just change the endpoint
          println("we're already searching...");
        }
      }
    }
  }

  public void draw() {
    background(backCol);
    if (noError) {
      fill(textCol);
      text(state, 20, 100); // I should change it for a more consistent solution with ControlP5
    }
    else {
      fill(200, 30, 10);
      text("Error", 20, 100);
    }
    fill(textCol);
    text(IDsaved.size()+" images downloaded", 20, 180);
    // text(rightNow.getTime().toString(), 20, 260);
    if (newImg != null && isSearching) {
      image(newImg, 20, 290, 360, 360);
    }
    else {
      image(placeholder, 20, 290, 360, 360);
    }
  }
  
  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public ControlP5 control() {
    return cp5;
  }
}
