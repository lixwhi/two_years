import de.looksgood.ani.*;
import com.hamoid.*;

VideoExport videoExport;
PFont font;


int FIRST_BLOCK = 4752000;
int LAST_BLOCK = 9118000;
int FADE_BLOCK = 9000000;
int KILL_BLOCK = 9118000;
int KILL_FRAME_ALPHA = 0;
int current_frame = 0;
int current_block = 0;
int FRAMES_PER_SECOND = 60;
int BLOCKS_PER_FRAME = 1000;

Cdp[] cdps;
MoneyPit moneypit;
Money[] moneys;
//int NUM_CDPS = 5000;
int NUM_CONTRACTS = 12;
int NUM_TRANSFERS = 10000;
//float SCALE_SCALER = 0.000015;
float SCALE_SCALER = 0.00351;
float POW_SCALER = 0.577350269;
float MONEY_MIN_DELAY = 0;
float MONEY_MAX_DELAY = 0.011;
float MONEY_MIN_DURATION = 0.07;
float MONEY_MAX_DURATION = 0.175;



color CONTRACT_COLOR = color(253, 193, 52, 255);
color MONEY_COLOR = color(249);

float CDP_MAX_DIAMETER = 20;
float CDP_MIN_DIAMETER = 0;
float CDP_TRUNC_DEBT_MAX = 9000000;
float CDP_TRUNC_DEBT_MIN = 100;
float CDP_CIRCLE_SIZE = 900; //diameter
//0.05 and 18 for 1080
//try 0.059 and 20 for 1440
float SPIRAL_SCALER = 0.05;
float THETA_ADDER = 18;
float CDP_BITE_EXTENSION = CDP_CIRCLE_SIZE + 20;
float BITE_MOVE_DURATION = 7;
float BITE_MOVE_DELAY = 0;
int BITE_TEXT_COLOR = 242;
int BITE_TEXT_SIZE = 16;
int BITE_TEXT_ALPHA = 233;
float BITE_DURATION = 20;
float BITE_DELAY = 0;

int CDP_ALPHA = 155;

int BACK = 23;
color RED =      color(138,     1,     0, CDP_ALPHA);
color REDYELLOW =color(250,   197,   37, CDP_ALPHA);
color YELLOW =  color( 242,   231,   19, CDP_ALPHA);
color GREEN0 = color(  205,   244,   34, CDP_ALPHA);
color GREEN1 = color(  192,   245,   34, CDP_ALPHA);
color GREEN2 = color(  178,   246,   34, CDP_ALPHA);
color GREEN3 = color(  162,   247,   34, CDP_ALPHA);
color GREEN4 = color(  158,   248,   33, CDP_ALPHA);
color GREEN5 = color(  134,   249,   32, CDP_ALPHA);
color GREEN6 = color(   57,   178,   25, CDP_ALPHA);
color GREEN7 = color(   28,   141,   11, CDP_ALPHA);
color[] colors = {RED,REDYELLOW, YELLOW , GREEN0 , GREEN1, GREEN2, GREEN3, GREEN4, GREEN5, GREEN6, GREEN7};

Table cdp_init_table;
Table cdp_table;
//Table transfer_table;
Table bust_table;
Table medianizer_table;

float money_pit_balance = 0;
float money_pit_dai_meter = 0;
float tap_circle_balance = 0;

float eth_price = 1000;


void setup()
{
  size(1920, 1080);
  Ani.init(this);
  font = loadFont("Waree-16.vlw");
  textFont(font);
  Ani.setDefaultTimeMode(Ani.FRAMES);
  //Ani.noAutostart();
  background(BACK);
  noStroke();
  //smooth();
  videoExport = new VideoExport(this);
  // Everything as by default except -vf (video filter)
  videoExport.setFfmpegVideoSettings(
    new String[]{
    "[ffmpeg]",                       // ffmpeg executable
    "-y",                             // overwrite old file
    "-f",        "rawvideo",          // format rgb raw
    "-vcodec",   "rawvideo",          // in codec rgb raw
    "-s",        "[width]x[height]",  // size
    "-pix_fmt",  "rgb24",             // pix format rgb24
    "-r",        "60",             // frame rate
    "-i",        "-",                 // pipe input

                                      // video filter with vignette, blur,
                                      // noise and text. font commented out
    //"-vf", "vignette,gblur=sigma=1,noise=alls=10:allf=t+u," +
    //"drawtext=text='Made with Processing':x=50:y=(h-text_h-50):fontsize=24:fontcolor=white@0.8",
    // drawtext=fontfile=/path/to/a/font/myfont.ttf:text='Made...

    "-an",                            // no audio
    "-vcodec",   "h264",              // out codec h264
    "-pix_fmt",  "yuv420p",           // color space yuv420p
    "-crf",      "0",             // quality 0 is lossless
    "-metadata", "comment=[comment]", // comment
    "[output]"                        // output file
    });

  // Everything as by default. Unused: no audio in this example.
  videoExport.setFfmpegAudioSettings(new String[]{
    "[ffmpeg]",                       // ffmpeg executable
    "-y",                             // overwrite old file
    "-i",        "[inputvideo]",      // video file path
    "-i",        "[inputaudio]",      // audio file path
    "-filter_complex", "[1:0]apad",   // pad with silence
    "-shortest",                      // match shortest file
    "-vcodec",   "copy",              // don't reencode vid
    "-acodec",   "aac",               // aac audio encoding
    "-b:a",      "[bitrate]k",        // bit rate (quality)
    "-metadata", "comment=[comment]", // comment
    // https://stackoverflow.com/questions/28586397/ffmpeg-error-while-re-encoding-video#28587897
    "-strict",   "-2",                // enable aac
    "[output]"                        // output file
    });
  videoExport.startMovie();
  frameRate(FRAMES_PER_SECOND);
  //noLoop();
  


  //init_pretend_cdps();
  //init_pretend_contracts();
  //init_pretend_money();
  
  cdp_init_table = loadTable("cdp_init_file.csv", "header");
  cdp_table = loadTable("cdp_interactions.csv", "header");
  bust_table = loadTable("cdp_busts.csv", "header");
  //transfer_table = loadTable("transfers_blocks_4752000-9097000.csv", "header");
  medianizer_table = loadTable("ethusd_medianizer_price.csv", "header");
  cdps = new Cdp[cdp_init_table.getRowCount()];
  for (int i = 0; i < cdps.length; i++){
    cdps[i] = new Cdp();
  }
  
  init_cdps();
  
  moneypit = new MoneyPit();
  moneypit.x_pos = width/2;
  moneypit.y_pos = height/2;
  moneypit.dai_meter = 0;
  moneypit.balance = 0;
  moneypit.name = "Supply";
  moneys = new Money[0];
  //for (int i = 0; i < moneys.length; i++){
  //  moneys[i] = new Money();
  //}
  drawLegends();
  
  
}

void draw()
{
  background(BACK);
  int startb = FIRST_BLOCK + (current_frame * BLOCKS_PER_FRAME);
  int endb = startb + BLOCKS_PER_FRAME;
  current_block = startb;
  for (TableRow row : cdp_table.rows()){
    if ((row.getInt("block") >= startb) && (row.getInt("block") < endb)){
      if(row.getString("action").equals("lock")){
        int cdp_indx = getIndexFromCdpid(row.getInt("cdpid"));
        cdps[cdp_indx].lockCollateral(row.getFloat("amount"));
      }
      if(row.getString("action").equals("wipe")){
        int cdp_indx = getIndexFromCdpid(row.getInt("cdpid"));
        cdps[cdp_indx].sendMoneyWipeDebt(row.getFloat("amount"));
        //sendMoney(width/2, height/2, cdps[row.getInt("cdpid")].x_pos, cdps[row.getInt("cdpid")].y_pos, row.getFloat("amount"));
      }
      if(row.getString("action").equals("draw")){
        int cdp_indx = getIndexFromCdpid(row.getInt("cdpid"));
        cdps[cdp_indx].drawDebtSendMoney(row.getFloat("amount"));
      }
      if(row.getString("action").equals("free")){
        int cdp_indx = getIndexFromCdpid(row.getInt("cdpid"));
        cdps[cdp_indx].freeCollateral(row.getFloat("amount"));
      }
      if(row.getString("action").equals("bite")){
        int cdp_indx = getIndexFromCdpid(row.getInt("cdpid"));
        cdps[cdp_indx].start_bite();
      }
    }
    else if (row.getInt("block") > endb){
      break;
    }
  }
  for (TableRow row : bust_table.rows()){
    if ((row.getInt("block") >= startb) && (row.getInt("block") < endb)){
      Money monmon = new Money();
      monmon.val = row.getFloat("amount");
      monmon.dai_meter = getCircleSizeFromBalance(monmon.val);
      monmon.x_pos = (width / 2) + random(-15, 15);
      monmon.y_pos = (height / 2) + random(-15, 15);
      monmon.x_dest = width * 7 / 8;
      monmon.y_dest = height / 4;
      monmon.frame_sent = current_frame;
      monmon.block_sent = current_block;
      monmon.sending = true;
      monmon.id_wiping = 0;
      if(current_frame > 60){
        monmon.animateToTap();
        moneys = (Money[]) append(moneys, monmon);
      }
    }
  }
  drawLegends();
  drawTap();
  updateEthPrice();
  updateCDPs();
  drawCDPs();
  drawMoneys();
  drawPit();
  
  //drawContracts();
  //drawMoneys();
  
  //println(current_frame);
  //println(eth_price);
  
  


 
 if (current_block >= FADE_BLOCK){
   fill(BACK, BACK, BACK, KILL_FRAME_ALPHA);
   rect(0, 0, width *4, height*4);
   Ani.to(this, 40, 0, "KILL_FRAME_ALPHA", 355, Ani.LINEAR);
   
   
 }
 if (current_block == KILL_BLOCK){
   exit();
 }
 videoExport.saveFrame();
 current_frame += 1;
}

//void sendMoney(float xs, float ys, float xe, float ye, float amt){
  
//}

//void init_pretend_money(){
//  for (int i = 0; i < moneys.length; i++){
//    int rand_indx_cdp = int(random(1, NUM_CDPS - 1));
//    int rand_indx_contract = int(random(1, NUM_CONTRACTS - 1));
//    if((rand_indx_cdp % 2) == 1) {
//      moneys[i].x_pos = cdps[rand_indx_cdp].x_pos;
//      moneys[i].y_pos = cdps[rand_indx_cdp].y_pos;
//      moneys[i].x_dest = contracts[rand_indx_contract].x_pos;
//      moneys[i].y_dest = contracts[rand_indx_contract].y_pos;
//    }
//    else {
//      moneys[i].x_dest = cdps[rand_indx_cdp].x_pos;
//      moneys[i].y_dest = cdps[rand_indx_cdp].y_pos;
//      moneys[i].x_pos = contracts[rand_indx_contract].x_pos;
//      moneys[i].y_pos = contracts[rand_indx_contract].y_pos;
//    }
//    moneys[i].val = random(2, 50000);
//    moneys[i].setDai_meter();
//    moneys[i].frame_sent = int(random(0, 600));
//  }
  
  
//}
//void init_pretend_contracts(){
//  for (int i = 0; i < contracts.length; i++){
//    contracts[i].x_pos = random(width / 3, width * 2 / 3);
//    contracts[i].y_pos = random(height / 4, height * 3 / 4);
//    contracts[i].balance = random(4000, 4000000);
//    contracts[i].setDai_meter();
//    contracts[i].name = "contrass" + str(i);
//  }
//}
void drawLegends(){
  textAlign(CENTER, CENTER);
  
  //float size100 = getCircleSizeFromBalance(100);
  //float size1000 = getCircleSizeFromBalance(1000);
  //float size10000 = getCircleSizeFromBalance(10000);
  float size50000 = getCircleSizeFromBalance(50000);
  float size500000 = getCircleSizeFromBalance(500000);
  float size5000000 = getCircleSizeFromBalance(5000000);
  float size50000000 = getCircleSizeFromBalance(50000000);
  pushMatrix();
  fill(MONEY_COLOR);
  ellipse(width/16, height * 4 / 35, size50000000, size50000000);
  popMatrix();
  pushMatrix();
  fill(BITE_TEXT_COLOR);
  text("50M", width * 3 / 27, height * 4 / 35);
  popMatrix();
  pushMatrix();
  fill(MONEY_COLOR);
  ellipse(width/16, height * 5 / 25, size5000000, size5000000);
  popMatrix();
  pushMatrix();
  fill(BITE_TEXT_COLOR);
  text("5M", width * 3 / 27, height * 5 / 25);
  popMatrix();
  pushMatrix();
  fill(MONEY_COLOR);
  ellipse(width/16, height * 6 / 25, size500000, size500000);
  popMatrix();
  pushMatrix();
  fill(BITE_TEXT_COLOR);
  text("500K", width * 3 / 27, height * 6 / 25);
  popMatrix();
  pushMatrix();
  fill(MONEY_COLOR);
  ellipse(width/16, height * 7 / 25, size50000, size50000);
  popMatrix();
  pushMatrix();
  fill(BITE_TEXT_COLOR);
  text("50K", width * 3 / 27, height * 7 / 25);
  popMatrix();
  

      
}
float getCircleSizeFromBalance(float bal){
  return pow(bal, POW_SCALER) * SCALE_SCALER;
}
void init_cdps(){
  int i = 0;
  for (TableRow row : cdp_init_table.rows()){
    cdps[i].debt = 0;
    cdps[i].setDai_meter();
    cdps[i].ratio = 5;
    cdps[i].collateral = 1;
    cdps[i].col = color(BACK);
    cdps[i].id = row.getInt("cdpid");
    cdps[i].block_created = row.getInt("blockcreated");
    cdps[i].setXY();
    cdps[i].recent_wipes = new float[0];
    cdps[i].recent_draws = new float[0];
    cdps[i].bite_text_until_frame = 0;
    cdps[i].indx = i;
    i++;
  }
}

//void init_pretend_cdps(){
//  for (int i = 0; i < cdps.length; i++){
//    cdps[i].debt = random(CDP_TRUNC_DEBT_MIN, CDP_TRUNC_DEBT_MAX);
//    cdps[i].setDai_meter();
//    cdps[i].ratio = random(1.5, 5);
//    cdps[i].collateral = cdps[i].debt * cdps[i].ratio;
//    cdps[i].col = colorFromRatio(cdps[i].ratio);
//    cdps[i].block_created = int(random(FIRST_BLOCK + 1, LAST_BLOCK - 1));
//    cdps[i].setXY();
//    if (i >= (NUM_CDPS - 5)){
//      cdps[i].start_bite();
//    }
//    cdps[i].bite_text_until_frame = 0;
    
//  }
  
//}
void updateEthPrice(){
  TableRow ethp = medianizer_table.findRow(str(current_block + BLOCKS_PER_FRAME), "block");
  eth_price = ethp.getFloat("price");
  
  
}
void updateCDPs(){
  for (int i = 0; i < cdps.length; i++){
    if((cdps[i].block_created < (current_block + BLOCKS_PER_FRAME)) && (cdps[i].debt > 49)){
      cdps[i].updateRatioAnis();
      cdps[i].updateDai_meterAnis();
    }
    else if(cdps[i].block_created < (current_block + BLOCKS_PER_FRAME)) {
      continue;
    }
    else{
      break;
    }
  }
}

void drawCDPs()
{ 
  for (int i = 0; i < cdps.length; i++){
    if(cdps[i].bite_text_until_frame > current_frame){
      cdps[i].drawBite();
    }
    
    
    if((cdps[i].block_created < current_block) && (cdps[i].debt > 49)){
      cdps[i].drawCDP();
      
    }
    
    else if(cdps[i].block_created < (current_block + BLOCKS_PER_FRAME)) {
      continue;
    }
    else{
      break;
    }
    
  }
}
void drawTap(){
  //Ani.to(this, 120, 0, "tap_circle_balance", 0, Ani.LINEAR);
  fill(MONEY_COLOR);
  if(tap_circle_balance <= 0){
    tap_circle_balance = 0;
  }
  float tap_dai_meter = getCircleSizeFromBalance(tap_circle_balance);
  ellipse(width * 7 / 8, height/4, tap_dai_meter, tap_dai_meter);
  
}

void drawPit(){
  fill(MONEY_COLOR);
  if(money_pit_balance < 0){
    money_pit_balance = 0;
  }
  else if(money_pit_balance > 130000000){
    money_pit_balance = 130000000;
  }
  Ani.to(this, 10, 0, "money_pit_dai_meter", getCircleSizeFromBalance(money_pit_balance), Ani.LINEAR);
  ellipse(width/2, height/2, money_pit_dai_meter, money_pit_dai_meter);
  
}
void drawMoneys()
{ 
  Money[] newmoneys = new Money[0];
  for (int i = 0; i < moneys.length; i++){
    if (moneys[i].sending){
      moneys[i].drawTheDot();
      newmoneys = (Money[]) append(newmoneys, moneys[i]);
    }
  }
  moneys = newmoneys;
}
int getIndexFromCdpid(int c){
  int indx = -1;
  for (int i = 0; i < cdps.length; i++){
    if(c == cdps[i].id){
      indx = cdps[i].indx;
    }
    if(indx != -1){
      break;
    }
  }
  if(indx == -1){
    indx = int(random(0, cdps.length));
  }
    
  
  return indx;
}
color colorFromRatio(float rat){
  float zero_mapped = 0;
  if (rat <= 1.5){
    rat = 1.5;
  }
  if (rat >= 4){
    rat = 4.0;
  }
  rat = rat - 1.5;
  zero_mapped = rat / 2.5;
  color cc = lerpColors(zero_mapped, colors);
  
  return cc;
}

//void lerpBar(int x, int y, int w, int h, color... colors) {
//  pushStyle();
//  for (int i=0; i<w; i++) {
//    stroke(lerpColors(float(i)/w, colors));
//    line(x+i, y, x+i, y+h);
//  }
//  popStyle();
//}
 
color lerpColors(float amt, color... colors) {
  if(colors.length==1){ return colors[0]; }
  float cunit = 1.0/(colors.length-1);
  return lerpColor(colors[floor(amt / cunit)], colors[ceil(amt / cunit)], amt%cunit/cunit);
}
