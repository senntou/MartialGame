import processing.net.*;
import java.lang.StringBuilder;

Server server;
enum StickManStatus{
    WAITING,
    PUNCH,
    KICK,
}
enum KeyStatus{
    CLICK,
    KEEP,
    DEFAULT,
}

float groundHeight;
StickMan playerOne;
StickMan playerTwo;

KeyStatusList keyListOne = new KeyStatusList();
KeyStatusList keyListTwo = new KeyStatusList();

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
    public void getInfo(StringBuilder sb){
        sb.append(currentHitPoint);
        sb.append(",");
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
public class KeyStatusList{
    boolean right;
    boolean left;
    KeyStatus punch;
    KeyStatus kick;
    public KeyStatusList() {
        this.right = false;
        this.left = false;
        this.punch = KeyStatus.DEFAULT;
        this.kick = KeyStatus.DEFAULT;
    }
}
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
    public void getInfo(StringBuilder sb){
        sb.append(this.x);
        sb.append(",");
        sb.append(this.y);
        sb.append(",");
    }
};
public class StickMan{
    private number;
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
    private int frameCount;
    private int waitFrameCycle;
    private int punchFrame;
    private int kickHalfFrame;
    private StickManStatus status;
    private float walkSpeed;
    private KeyStatusList keyList;
    
    private HitPointBar hp;
    public String getInfo(){
        StringBuilder sb = new StringBuilder();
        base.getInfo(sb);
        sb.append(headSize);
        sb.append(",");
        head.getInfo(sb);
        crotch.getInfo(sb);
        sb.append(direction);
        sb.append(",");
        sb.append(height);
        sb.append(",");
        sb.append(stickLength);
        sb.append(",");
        lfeet.getInfo(sb);
        rfeet.getInfo(sb);
        lhand.getInfo(sb);
        rhand.getInfo(sb);
        shoulder.getInfo(sb);
        hp.getInfo(sb);
        return sb.toString();
    }
    public StickMan(int dir,KeyStatusList keyList) {
        this.direction = dir;
        this.base = new Point(width / 3,groundHeight);
        this.height = 180;
        this.resetPoint(0);
        this.headSize = 50;
        this.stickLength = (height - headSize) / 3;
        this.frameCount = 0;
        this.waitFrameCycle = 30;
        this.punchFrame = 15;
        this.kickHalfFrame = 10;
        this.status = StickManStatus.WAITING;
        this.resetPoint(0);
        
        this.walkSpeed = 3;
        this.keyList = keyList;
        this.hp = new HitPointBar(100);
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
    void move() {
        if (this.keyList.right) base.addx(walkSpeed);
        if (this.keyList.left) base.addx( -walkSpeed);
    }
    void resetPoint(float delta) {
        this.head = new Point(this.base.getx(),this.base.gety() - this.height + delta);
        this.crotch = new Point(head.getx() - (direction * 10),
            this.base.gety() - (this.height + headSize / 2) / 3 + delta
           );
        this.lfeet = new Point(crotch.getx() - 30,this.base.gety());
        this.rfeet = new Point(crotch.getx() + 30,this.base.gety());
        this.shoulder = new Point(
           (crotch.getx() + head.getx() * 2) / 3,
           (crotch.gety() + (head.gety() + headSize / 2) * 2) / 3
           );
        this.lhand = new Point(
            shoulder.getx() + stickLength * 5 / 4,
            shoulder.gety() + delta
           );
        this.rhand = new Point(
            shoulder.getx() + stickLength / 5,
            shoulder.gety() + height / 15 + delta
           );
    }
    void startPunch() {
        this.status = StickManStatus.PUNCH;
        this.frameCount = 0;
        this.keyList.punch = KeyStatus.KEEP;
    }
    void endMotion() {
        this.status = StickManStatus.WAITING;
        frameCount = 0;
    }
    void startKick() {
        this.status = StickManStatus.KICK;
        frameCount = 0;
        this.keyList.kick = KeyStatus.KEEP;
    }
    
    void update() {
        switch(this.status) {
            case WAITING:
                frameCount++;
                frameCount %= waitFrameCycle;
                if (this.keyList.right && !this.keyList.left) this.direction = 1;
                else if (this.keyList.left && !this.keyList.right) this.direction = -1;
                float delta = frameCount > waitFrameCycle / 2 ? waitFrameCycle - frameCount : frameCount;
                delta = map(delta * delta,0,(waitFrameCycle * waitFrameCycle / 4),0,height / 9);
                this.resetPoint(delta);
                break;
            case PUNCH:
                this.resetPoint(0);
                frameCount++;
                float punchLength = frameCount > punchFrame / 2 ? punchFrame - frameCount : frameCount;
                lhand.addx(punchLength * 5);
                if (frameCount >= punchFrame) this.endMotion();
                break;
            case KICK:
                this.resetPoint(0);
                this.crotch.addx(this.direction * headSize / 3);
                frameCount++;
                int kCnt = frameCount > kickHalfFrame ? kickHalfFrame * 2 - frameCount : frameCount;
                Point kickGoal = new Point(this.head.getx() + headSize * 1.5 * this.direction,this.head.gety());
                //内分点
                Point kfeet = (this.direction == 1 ? this.rfeet : this.lfeet);
                kfeet.setx(kickGoal.getx() * kCnt / kickHalfFrame + kfeet.getx() * (kickHalfFrame - kCnt) / kickHalfFrame);
                kfeet.sety(kickGoal.gety() * kCnt / kickHalfFrame + kfeet.gety() * (kickHalfFrame - kCnt) / kickHalfFrame);
                if (frameCount >= kickHalfFrame * 2) this.endMotion();
                break;
        }
        this.draw();
        this.move();
        this.hp.draw();
        
        if (this.keyList.punch == KeyStatus.CLICK) this.startPunch();
        if (this.keyList.kick == KeyStatus.CLICK) this.startKick();
    }
    
}
void keyPressed() {
    if (keyCode == RIGHT) keyListOne.right = true;
    if (keyCode == LEFT) keyListOne.left = true; 
    if (key == 'z' && keyListOne.punch == KeyStatus.DEFAULT) keyListOne.punch = KeyStatus.CLICK;
    if (key == 'x' && keyListOne.kick == KeyStatus.DEFAULT) keyListOne.kick = KeyStatus.CLICK;   
    
    if (key == 'r') keyListTwo.right = true;
    if (key == 'q') keyListTwo.left = true; 
    if (key == 'w' && keyListTwo.punch == KeyStatus.DEFAULT) keyListTwo.punch = KeyStatus.CLICK;
    if (key == 'e' && keyListTwo.kick == KeyStatus.DEFAULT) keyListTwo.kick = KeyStatus.CLICK;  
}
void keyReleased() {
    if (keyCode == RIGHT) keyListOne.right = false;
    if (keyCode == LEFT) keyListOne.left = false;
    if (key == 'z') keyListOne.punch = KeyStatus.DEFAULT;
    if (key == 'x') keyListOne.kick = KeyStatus.DEFAULT; 
    
    if (key == 'r') keyListTwo.right = false;
    if (key == 'q') keyListTwo.left = false; 
    if (key == 'w') keyListTwo.punch = KeyStatus.DEFAULT;
    if (key == 'e') keyListTwo.kick = KeyStatus.DEFAULT;
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

void getCommandFromCliend() {
    Client c = server.available();
    if (c != null) {
        String st = c.readString();
        String cmd[] = st.split(",");
        boolean one = false;
        boolean two = false;
        for (String s : cmd) {
            println(s);
            if (s.equals("one")) {
                one = true;
                continue;
            }
            if (s.equals("two")) {
                two = true;
                continue;
            }
            if (one) {
                if (s.equals("PRIGHT")) {
                    keyListOne.right = true;
                }
                if (s.equals("PLEFT")) {
                    keyListOne.left = true;
                }
                if (s.equals("RRIGHT")) {
                    keyListOne.right = false;
                }
                if (s.equals("RLEFT")) {
                    keyListOne.left = false;
                }
                if (s.equals("PZ")) {
                    key = 'z';
                    keyPressed();
                }
                if (s.equals("RZ")) {
                    key = 'z';
                    keyReleased();
                }
                if (s.equals("PX")) {
                    key = 'x';
                    keyPressed();
                }
                if (s.equals("RX")) {
                    key = 'x';
                    keyReleased();
                }
                one = false;
            }
            if (two) {
                if (s.equals("PRIGHT")) {
                    keyListTwo.right = true;
                }
                if (s.equals("PLEFT")) {
                    keyListTwo.left = true;
                }
                if (s.equals("RRIGHT")) {
                    keyListTwo.right = false;
                }
                if (s.equals("RLEFT")) {
                    keyListTwo.left = false;
                }
                if (s.equals("PZ")) {
                    key = 'w';
                    keyPressed();
                }
                if (s.equals("RZ")) {
                    key = 'w';
                    keyReleased();
                }
                if (s.equals("PX")) {
                    key = 'e';
                    keyPressed();
                }
                if (s.equals("RX")) {
                    key = 'e';
                    keyReleased();
                }
                one = false;
            }
            
        }
    }
}
void sendPlayerOneInfo(){
    String s = "one," + playerOne.getInfo();
    server.write(s);
}
void sendPlayerTwoInfo(){
    String s = "two," + playerTwo.getInfo();
    server.write(s);
}

void setup() {
    server = new Server(this, 20000);
    println("start server at address: " + server.ip());
    size(800,600);
    frameRate(60);
    groundHeight = height * 4 / 5;
    playerOne = new StickMan(1,keyListOne);
    playerTwo = new StickMan( -1,keyListTwo);
    smooth();
}

void draw() {
    sendPlayerOneInfo();
    sendPlayerTwoInfo();

    getCommandFromCliend();
    background(255);

    
    drawGround();
    
    playerOne.update();
    playerTwo.update();
}
