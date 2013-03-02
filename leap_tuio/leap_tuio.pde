/**
 * @author Hamzeen. H. (http://blog.hamzeen.com)
 * @created 03-01-2013
 */
import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.Finger;

LeapMotionP5 leap;
private ArrayList<PVector> hands;
private ArrayList<TuioPoint> tuioPoints;
private OSCInterface oscInterface;

private long startTime;
private long lastTime = 0;
private int cw = 500;
private int ch = 500;
private int sessionId = 0;
private String sourceName;
private int counter_fseq = 0;

void setup() {
  size(500, 500);
  leap = new LeapMotionP5(this);
  oscInterface = new OSCInterface("127.0.0.1",3333);
  hands = new ArrayList<PVector>();
  tuioPoints = new ArrayList<TuioPoint>();
  sourceName = "127.0.0.1";
}

void draw() {
  background(0);
  fill(255);
  hands.clear();
  tuioPoints.clear();
  hands.trimToSize();
  
  for (Finger finger : leap.getFingerList()) {
    PVector fingerPos = leap.getTip(finger);
    ellipse(fingerPos.x, fingerPos.y, 10, 10);
    PVector pos = new PVector(fingerPos.x, fingerPos.y);
    hands.add(pos);
  }
  
  
  long timeStamp = System.currentTimeMillis() - startTime;
  long dt = timeStamp - lastTime;
  lastTime = timeStamp;
  dt = 1000;
  int pointerCount = hands.size();
  boolean pointStillAlive = true;
  
  for (int i = 0; i < pointerCount; i++) {
	int id = i+1;
	float x = hands.get(i).x;
	float y = hands.get(i).y;

	boolean pointExists = false;
	for (int j = 0; j < tuioPoints.size(); j++) {
	  if (tuioPoints.get(j).getTouchId() == id) {
		  tuioPoints.get(j).update(x / cw, y / ch, timeStamp);
		  pointExists = true;
		  break;
	  }
	}
        if(!pointExists){
          tuioPoints.add(new TuioPoint(id, id, x / cw, y / ch, timeStamp));
	}
        //sessionId++;
  }
  sendTUIOdata();
}

void stop() {
  leap.stop();
}


public void sendTUIOdata() throws ArrayIndexOutOfBoundsException {
  OSCBundle oscBundle = new OSCBundle();

  Object outputData[] = new Object[2];
  outputData[0] = "source";
  outputData[1] = sourceName;
  oscBundle.addPacket(new OSCMessage("/tuio/2Dcur", outputData));

  outputData = new Object[tuioPoints.size() + 1];
  outputData[0] = "alive";
  for (int i = 0; i < tuioPoints.size(); i++) {
	outputData[1 + i] = (Integer) tuioPoints.get(i).getSessionId(); // ID
  }
  oscBundle.addPacket(new OSCMessage("/tuio/2Dcur", outputData));

  for (int i = 0; i < tuioPoints.size(); i++) {
	outputData = new Object[7];

	outputData[0] = "set";
	outputData[1] = (Integer) tuioPoints.get(i).getSessionId(); // ID
	outputData[2] = (Float) tuioPoints.get(i).getX(); // x KOORD
	outputData[3] = (Float) tuioPoints.get(i).getY(); // y KOORD

	outputData[4] = (Float) tuioPoints.get(i).getXVel(); // Velocity Vector X
	outputData[5] = (Float) tuioPoints.get(i).getYVel(); // Velocity Vector Y
	outputData[6] = (Float) tuioPoints.get(i).getAccel(); // Acceleration

	oscBundle.addPacket(new OSCMessage("/tuio/2Dcur", outputData));
  }
  outputData = new Object[2];
  outputData[0] = (String) "fseq";
  outputData[1] = (Integer) counter_fseq;
  counter_fseq++;

  oscBundle.addPacket(new OSCMessage("/tuio/2Dcur", outputData));
  
  oscInterface.sendOSCBundle(oscBundle);
}
