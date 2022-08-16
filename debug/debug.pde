import processing.net.*;
String serverAddress = "192.168.11.3";
Client client;

String pass = "two,";

float groundHeight;
StickMan playerOne;
StickMan playerTwo;
public class Point{
    private float x;
    private float y;
    public Point(float x,float y) {
        this.x = x;
        this.y = y;
    }
    public void setx(float x) {
        this.x = x;
    }
    public void sety(float y) {
        this.y = y;
    }
    public float getx() {
        return this.x;
    }
    public float gety() {
        return this.y;
    }
    public void addx(float a) {
        this.x += a;
    }
    public void addy(float a) {
        this.y += a;
    }
};
public class HitPointBar{
    private float hitPointMax;
    private float currentHitPoint;
    final Point barCenterPoint;
    final float HPBwidth;
    final float HPBheight;
    public HitPointBar(float hp) {
        this.hitPointMax = hp;
        this.currentHitPoint = hp;
        barCenterPoint = new Point(width / 4 ,(groundHeight + height) / 2);
        this.HPBwidth = width / 2 - 40;
        this.HPBheight = 50;
    }
    void setHp(float hp){
        this.currentHitPoint = hp;
    }
    void draw() {
        noStroke();
        fill(255,0,0);
        pushMatrix();
        translate(barCenterPoint.getx(),barCenterPoint.gety());
        translate( -this.HPBwidth / 2, -this.HPBheight / 2);
        rect(0,0,this.HPBwidth,this.HPBheight);
        popMatrix();
    }
}
public class StickMan{
    private Point base;
    private float headSize;
    private Point head;
    private Point crotch;
    //left = -1,right = 1とする(多分列挙型より楽？)
    private int direction;
    private float height;
    private float stickLength;
    private Point lfeet;
    private Point rfeet;
    private Point lhand;
    private Point rhand;
    private Point shoulder;
    
    private HitPointBar hp;
    
    public StickMan(int dir) {
        base = new Point(0,0);
        headSize = 0;
        head = new Point(0,0);
        crotch = new Point(0,0);
        direction = dir;
        height = 0;
        stickLength = 0;
        lfeet = new Point(0,0);
        rfeet = new Point(0,0);
        lhand = new Point(0,0);
        rhand = new Point(0,0);
        shoulder = new Point(0,0);
        
        hp = new HitPointBar(100);
    }
    public void readPlayerInfo(String s){
        String cmd[] = s.split(",");
        int index = 1;
        base.setx(Float.valueOf(cmd[index++]));
        base.sety(Float.valueOf(cmd[index++]));
        headSize = Float.valueOf(cmd[index++]);
        head.setx(Float.valueOf(cmd[index++]));
        head.sety(Float.valueOf(cmd[index++]));

        crotch.setx(Float.valueOf(cmd[index++]));
        crotch.sety(Float.valueOf(cmd[index++]));
        direction = Integer.valueOf(cmd[index++]);
        height = Float.valueOf(cmd[index++]);
        stickLength = Float.valueOf(cmd[index++]);

        lfeet.setx(Float.valueOf(cmd[index++]));
        lfeet.sety(Float.valueOf(cmd[index++]));
        rfeet.setx(Float.valueOf(cmd[index++]));
        rfeet.sety(Float.valueOf(cmd[index++]));
        lhand.setx(Float.valueOf(cmd[index++]));

        lhand.sety(Float.valueOf(cmd[index++]));
        rhand.setx(Float.valueOf(cmd[index++]));
        rhand.sety(Float.valueOf(cmd[index++]));
        shoulder.setx(Float.valueOf(cmd[index++]));
        shoulder.sety(Float.valueOf(cmd[index++]));
        hp.setHp( Float.valueOf(cmd[index++]) );
    }
    void draw() {
        strokeWeight(5);
        stroke(0);
        noFill();
        
        drawHead();
        drawBody();
        drawFoot(this.lfeet);
        drawFoot(this.rfeet);
        drawArm(this.lhand);
        drawArm(this.rhand);
        
        this.hp.draw();
    }
    void drawHead() {
        ellipse(head.getx(),head.gety(),headSize,headSize);
    }
    void drawBody() {
        line(head.getx(),head.gety() + headSize / 2,crotch.getx(),crotch.gety());
    }
    void drawFoot(Point feet) {
        //股から膝までの長さをStickLength,膝から足までもStickLength
        //となるように、膝を折り曲げる
        pushMatrix();
        translate(crotch.getx(),crotch.gety());
        
        int dir;
        float R = 1;
        {
            float squaredX = (crotch.getx() - feet.getx());
            dir = squaredX < 0 ? 1 : - 1;
            squaredX *= squaredX;
            float squaredY = (crotch.gety() - feet.gety());
            squaredY *= squaredY;
            R = sqrt(squaredX + squaredY);
        }
        float theta = acos((feet.gety() - crotch.gety()) / R);
        rotate( -dir * theta);
        theta = acos(constrain(R / (2 * stickLength), -1,1));
        line(0,0,direction * stickLength * sin(theta),R / 2);
        line(direction * stickLength * sin(theta),R / 2,0,R);
        popMatrix();
        
        //ellipse(feet.getx(),feet.gety(),5,5);
    }
    void drawArm(Point hand) {
        //股から膝までの長さをStickLength,膝から足までもStickLength
        //となるように、膝を折り曲げる
        pushMatrix();
        translate(shoulder.getx(),shoulder.gety());
        
        float R = 1;
        {
            float squaredX = (shoulder.getx() - hand.getx());
            squaredX *= squaredX;
            float squaredY = (shoulder.gety() - hand.gety());
            squaredY *= squaredY;
            R = sqrt(squaredX + squaredY);
        }
        float theta = atan((shoulder.getx() - hand.getx()) / (shoulder.gety() - hand.gety()));
        rotate( -direction * abs(theta));
        theta = acos(constrain(R / (2 * stickLength) , -1 , 1));
        line(0,0, -this.direction * stickLength * sin(theta),R / 2);
        line( -this.direction * stickLength * sin(theta),R / 2,0,R);
        popMatrix();
        //ellipse(shoulder.getx(),shoulder.gety(),5,5);
    }
    
}
void drawGround() {
    noStroke();
    fill(30);
    
    pushMatrix();
    translate(0,groundHeight);
    rectMode(CORNER);
    rect(0,0,width,height);
    
    popMatrix();
}

void setup() {
    client = new Client(this,serverAddress, 20000);
    size(800,600);
    frameRate(60);
    groundHeight = height * 4 / 5;
    playerOne = new StickMan(1);
    playerTwo = new StickMan( -1);
    smooth();
}
void draw() {
    background(255);

    drawGround();
    playerOne.draw();
    playerTwo.draw();
}

void keyPressed() {
    client.write(pass);
    if (keyCode == RIGHT) {
        client.write("PRIGHT,");
    }
    if (keyCode == LEFT) {
        client.write("PLEFT,");
    }
    if (key == 'z') {
        client.write("PZ");
    }
    if (key == 'x') {
        client.write("PX");
    }
}
void keyReleased() {
    client.write(pass);
    if (keyCode == RIGHT) {
        client.write("RRIGHT,");
    }
    if (keyCode == LEFT) {
        client.write("RLEFT,");
    }
    if (key == 'z') {
        client.write("RZ");
    }
    if (key == 'x') {
        client.write("RX");
    }
}
void clientEvent(Client c) {
    String s = c.readString();
    if (false/*s.length() > 10*/) {
        //print("received from server: " + s);
        int index = 0;
        if(s.startsWith("one")){
            playerOne.readPlayerInfo(s);
        }
        if(s.startsWith("two")){
            playerTwo.readPlayerInfo(s);
        } 
    }
}