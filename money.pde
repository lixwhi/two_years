class Money{
  float val;
  float dai_meter;
  float x_pos;
  float y_pos;
  float x_dest;
  float y_dest;
  int frame_sent;
  int block_sent;
  int id_wiping;
  int indx_wiping;
  boolean sending = false;
  void setDai_meter(){
    this.dai_meter = getCircleSizeFromBalance(this.val);
  }
  //void initTransfer(){
  //  this.sending = true;
  //  float rand_dur = random(MONEY_MIN_DURATION, MONEY_MAX_DURATION);
  //  float rand_del = random(MONEY_MIN_DELAY, MONEY_MAX_DELAY);
  //  Ani.to(this, rand_dur, rand_del, "x_dest", x_dest, Ani.QUAD_IN_OUT, "onEnd:killTransfer");
  //  Ani.to(this, rand_dur, rand_del, "y_dest", y_dest, Ani.QUAD_IN_OUT);
  //}
  void killTransfer(){
    this.sending = false;
  }
  void drawTheDot(){
    fill(MONEY_COLOR);
    ellipse(this.x_pos, this.y_pos, this.dai_meter, this.dai_meter);
  }
  void animateWipe(int ind){
    int frame_delay = int(random(0,3));
    Ani.to(this, 35, frame_delay, "x_pos", cdps[ind].x_pos, Ani.LINEAR, "onEnd:wipeDebt");
    Ani.to(this, 35, frame_delay, "y_pos", cdps[ind].y_pos, Ani.LINEAR);
  }
  void animateDraw(int idd){
    Ani.to(this, 5, 0, "dai_meter", getCircleSizeFromBalance(this.val), Ani.LINEAR, "onEnd:draw2");
    
  }
  void wipeDebt(){
    cdps[this.indx_wiping].wipeDebt();
    Ani.to(this, 17, 0, "dai_meter", 0, Ani.LINEAR, "onEnd:makeInvisible");
  }
  void draw2(){
    int frame_delay = 0;
    Ani.to(this, 35, frame_delay, "x_pos", width/2, Ani.LINEAR, "onEnd:draw3");
    Ani.to(this, 35, frame_delay, "y_pos", height/2, Ani.LINEAR);
  }
  void draw3(){
    this.sending = false;
    money_pit_balance += this.val;
  }
  void makeInvisible(){
    this.sending = false;
  }
  void animateToTap(){
    money_pit_balance -= this.val;
    Ani.to(this, 45, 0, "x_pos", this.x_dest, Ani.LINEAR,"onEnd:draw4");
    Ani.to(this, 45, 0, "y_pos", this.y_dest, Ani.LINEAR);
  }
  void draw4(){
    tap_circle_balance += this.val;
    Ani.to(this, 10, 0, "dai_meter", 0, Ani.SINE_OUT, "onEnd:makeInvisible");
  }
}
