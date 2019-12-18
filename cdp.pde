class Cdp {
  float debt;
  float[] recent_wipes;
  float[] recent_draws;
  float collateral;
  float dai_meter;
  float x_pos, y_pos;
  int id;
  float ratio;
  color col;
  int block_created;
  int text_tr = 0;
  int bite_text_until_frame;
  color bite_text_color;
  int indx;
  
  //void setDebt(float d){
  //  debt = d;
  //}
  float getDebt(){
    return debt;
  }
  void lockCollateral(float cc){
    this.collateral += cc;
    //this.ratio = (eth_price * this.collateral) / this.debt;
  }
  void freeCollateral(float cc){
    this.collateral -= cc;
    //this.ratio = (eth_price * this.collateral) / this.debt;
  }
  void sendMoneyWipeDebt(float dd){
    
    this.recent_wipes = append(this.recent_wipes, dd);
    
    money_pit_balance -= dd;
    
    Money monmon = new Money();
    monmon.val = dd;
    monmon.dai_meter = getCircleSizeFromBalance(dd);
    monmon.x_pos = width / 2 + random(-17, 17);
    monmon.y_pos = height / 2 + random(-17, 17);
    monmon.x_dest = this.x_pos;
    monmon.y_dest = this.y_pos;
    monmon.frame_sent = current_frame;
    monmon.block_sent = current_block;
    monmon.sending = true;
    monmon.id_wiping = this.id;
    monmon.indx_wiping = this.indx;
    
    if(current_frame > 60){
      monmon.animateWipe(this.indx);
      moneys = (Money[]) append(moneys, monmon);
    }
    
    
    
  }
  void drawDebtSendMoney(float dd){
    this.debt += dd;
    Money monmon = new Money();
    monmon.val = dd;
    monmon.dai_meter = 0;
    monmon.x_pos = this.x_pos;
    monmon.y_pos = this.y_pos;
    monmon.x_dest = width/2 + random(-17, 17);
    monmon.y_dest = height/2 + random(-17, 17);
    monmon.frame_sent = current_frame;
    monmon.block_sent = current_block;
    monmon.sending = true;
    monmon.id_wiping = this.id;
    monmon.indx_wiping = this.indx;
    monmon.animateDraw(this.id);
    moneys = (Money[]) append(moneys, monmon);
  }
  
  void wipeDebt(){
    for (int i= 0; i < this.recent_wipes.length; i++){
      this.debt -= this.recent_wipes[i];
      if(this.debt < 0 ){
        this.debt = 0;
      }
      
      
    }
    this.recent_wipes = new float[0];
    
    //this.ratio = (eth_price * this.collateral) / this.debt;
  }
  void drawDebt(float ee){
    this.debt += ee;
    //this.ratio = (eth_price * this.collateral) / this.debt;
  }
  void initAni(){
    Ani.to(this, random(0,1), random(0,2), "dai_meter", random(0, 5), Ani.EXPO_IN_OUT);
  }
  void drawCDP(){
    this.col = colorFromRatio(this.ratio);
    fill(this.col);
    ellipse(this.x_pos, this.y_pos, this.dai_meter, this.dai_meter);
  }
  void updateRatioAnis(){
    float rat_calc = eth_price * this.collateral / this.debt;
    if(this.debt == 0){
      rat_calc = 5;
    }
    Ani.to(this, 25, 0, "ratio", rat_calc, Ani.LINEAR);
  }
  void updateDai_meterAnis(){
    Ani.to(this, 15, 0, "dai_meter", getCircleSizeFromBalance(this.debt), Ani.LINEAR);
  }
  void drawBite(){
    if((this.id != 1272) && (this.id != 2028) && (this.id != 4898)){
      float theta = float(this.block_created - FIRST_BLOCK) / float((LAST_BLOCK - FIRST_BLOCK)) * TWO_PI * 1;
      float x_at_bite = ((CDP_BITE_EXTENSION * SPIRAL_SCALER * (THETA_ADDER + theta) / 2) * cos(-4 * theta)) + width/2;
      float y_at_bite = ((CDP_BITE_EXTENSION * SPIRAL_SCALER * (THETA_ADDER + theta) / 2) * sin(-4 * theta)) + height/2;
      color c = color(BITE_TEXT_COLOR, BITE_TEXT_COLOR, BITE_TEXT_COLOR, text_tr);
      this.bite_text_color = c;
      pushMatrix();
      fill(this.bite_text_color);
      textAlign(CENTER, CENTER);
      //textSize(BITE_TEXT_SIZE); 
      text(this.id, x_at_bite, y_at_bite);
      popMatrix();
    }
    
  }

  void setDai_meter(){
    float realdia;
    if(this.debt >= CDP_TRUNC_DEBT_MAX){
      realdia = CDP_TRUNC_DEBT_MAX;
    }
    else if(this.debt <= CDP_TRUNC_DEBT_MIN){
      realdia = CDP_TRUNC_DEBT_MIN;
    }
    else {
      realdia = this.debt;
    }
    //float zero_mapped = (realdia - CDP_TRUNC_DEBT_MIN) / (CDP_TRUNC_DEBT_MAX - CDP_TRUNC_DEBT_MIN);
    this.dai_meter = getCircleSizeFromBalance(realdia);
    
    
  }
  void setXY(){
    //0.05 and 18 for 1080
    //try 0.059 and 20 for 1440
    float theta = float(this.block_created - FIRST_BLOCK) / float((LAST_BLOCK - FIRST_BLOCK)) * TWO_PI * 1;
    this.x_pos = ((CDP_CIRCLE_SIZE * SPIRAL_SCALER * (THETA_ADDER + theta) / 2) * cos(-4 * theta)) + width/2;
    this.y_pos = ((CDP_CIRCLE_SIZE * SPIRAL_SCALER * (THETA_ADDER + theta) / 2) * sin(-4 * theta)) + height/2;
  }
  void start_bite(){
    float theta = float(this.block_created - FIRST_BLOCK) / float((LAST_BLOCK - FIRST_BLOCK)) * TWO_PI * 1;
    float x_at_bite = ((CDP_BITE_EXTENSION * SPIRAL_SCALER * (THETA_ADDER + theta) / 2) * cos(-4 * theta)) + width/2;
    float y_at_bite = ((CDP_BITE_EXTENSION * SPIRAL_SCALER * (THETA_ADDER + theta) / 2) * sin(-4 * theta)) + height/2;

    Ani.to(this, BITE_MOVE_DURATION, BITE_MOVE_DELAY, "x_pos", x_at_bite, Ani.ELASTIC_OUT, "onEnd:biteme");
    Ani.to(this, BITE_MOVE_DURATION, BITE_MOVE_DELAY, "y_pos", y_at_bite, Ani.ELASTIC_OUT);
  }
  void biteme(){
    
    Ani bite_ani = new Ani(this, BITE_DURATION, BITE_DELAY, "text_tr", BITE_TEXT_ALPHA, Ani.SINE_OUT);
    bite_ani.setPlayMode(Ani.YOYO);
    bite_ani.repeat(2);
    
    Ani.to(this, BITE_DURATION/4, BITE_DELAY/4, "col", color(BACK, BACK, BACK, 0), Ani.SINE_OUT, "onEnd:setDebt0");
    this.bite_text_until_frame = current_frame + 100;
  }
  void setDebt0(){
    Ani.to(this, 20, 0, "debt", 0, Ani.SINE_OUT, "onEnd:makeSure");
  }
  void makeSure(){
    this.text_tr = 0;
    this.debt = 0;
    this.bite_text_color = color(BACK);
  }
  void kill_text_tr(){
    this.text_tr = 0;
  }
}
