/**
 * @author Hamzeen. H. (http://blog.hamzeen.com)
 * @created 03-01-2013
 */
import com.onformative.leap.LeapMotionP5;
import com.onformative.leap.LeapGestures;
import controlP5.*;
import java.awt.AWTException;
import java.awt.Robot;

Robot robot;
LeapMotionP5 leap;
ControlP5 cp5;

int gestureCount = 0;
String lastGesture = "";

public void setup() {
  size(500, 500);
  textSize(30);

  leap = new LeapMotionP5(this);
  cp5 = new ControlP5(this);

  leap.addGesture(LeapGestures.SWIPE_LEFT);
  leap.addGesture(LeapGestures.SWIPE_RIGHT);
  leap.start();
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }
}

public void draw() {
  background(0);
  leap.gestures.one.draw();
  leap.update();
  text(lastGesture, 30, 30);
}

public void gestureRecognized(String gesture) {
  gestureCount++;
  lastGesture = gesture+" "+gestureCount;
  if(gesture.equals("swipeleft")){
	robot.keyPress(37);
    robot.keyRelease(37);
  }
  else if(gesture.equals("swiperight")){
	robot.keyPress(39);
    robot.keyRelease(39);
  }
}

public void stop() {
  leap.stop();
}
