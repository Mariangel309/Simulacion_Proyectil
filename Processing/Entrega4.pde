import processing.sound.*;

SoundFile backgroundMusic1;
SoundFile backgroundMusic2;
SoundFile startSound;
SoundFile buttonstart;
SoundFile buttonstop;

float v0 = 60; // Velocidad inicial
float theta = radians(60); // Ángulo de lanzamiento
float g = 9.8; // Gravedad
float h = 50; // Altura inicial
float t = 0; // Tiempo
float dt = 0.1; // Incremento de tiempo
float cd = 0; // Resistencia del aire
float vx;
float vy;
int resetButtonX, resetButtonY, resetButtonWidth, resetButtonHeight;
color resetButtonColor, resetTextColor;
ArrayList<Float> xPositions = new ArrayList<Float>();  
ArrayList<Float> yPositions = new ArrayList<Float>();
ArrayList<ArrayList<Float>> allXPositions = new ArrayList<ArrayList<Float>>();  // Para almacenar todas las trayectorias de x
ArrayList<ArrayList<Float>> allYPositions = new ArrayList<ArrayList<Float>>();  // Para almacenar todas las trayectorias de y

boolean startSimulation = false;
boolean onStartScreen = true;
boolean onDocumentation = false;

PFont font;

// Interfaz de inicio
int buttonX, buttonY, buttonWidth, buttonHeight, buttonDocX, buttonDocY, buttonDocWidth, buttonDocHeight; 
color buttonColor, textColor;
String buttonText = "Iniciar";
String buttonDocText = "Documentacion";
PFont buttonFont;
PFont titleFont;

PImage baseballField;
PImage[] pitcherImages;
PImage baseballImage;

int currentFrame = 0;
boolean pitching = false;
float ballX, ballY;
float ballSpeedX, ballSpeedY;
float ballScale = 0.005;
int frameDelay = 10;
int frameCounter = 0;
float pitcherScale = 0.12;
int screenState = 0;

// Controles de la interfaz
Slider velocidadSlider, anguloSlider, resistenciaSlider;

void setup() {
  size(980, 700);
  backgroundMusic1 = new SoundFile(this, "background1.mp3");
  backgroundMusic1.loop();
  backgroundMusic2 = new SoundFile(this, "background2.mp3");
  startSound = new SoundFile(this, "initsound.mp3");
  buttonstart = new SoundFile(this, "button.mp3");
  buttonstop = new SoundFile(this, "button.mp3");
  
  font = createFont("Arial", 16, true);
  textFont(font);
  background(200, 220, 255);
  frameRate(60);
  
  // Inicialización de sliders
  velocidadSlider = new Slider(50, height - 160, 150, 20, 0, 100, v0);
  anguloSlider = new Slider(250, height - 160, 150, 20, 0, 90, degrees(theta));
  resistenciaSlider = new Slider(450, height - 160, 150, 20, 0, 1, cd);
  
  // Inicializacion de imagenes
  baseballField = loadImage("cancha.jpg");
  baseballField.resize(width, height);
  
  pitcherImages = new PImage[3];
  for (int i = 0; i < pitcherImages.length; i++) {
    pitcherImages[i] = loadImage("pitcher" + (i+1) + ".png");
  }
  
  baseballImage = loadImage("pelota.png");

  buttonWidth = 150;
  buttonHeight = 50;
  buttonX = width / 2 - buttonWidth / 2;
  buttonY = height - buttonHeight - 20;
  buttonColor = color(128);
  textColor = color(255);
  
  buttonDocWidth = 250;
  buttonDocHeight = 50;
  buttonDocX = 20;
  buttonDocY = 20;
  
  // Inicializa el botón de reiniciar
  resetButtonWidth = 150;
  resetButtonHeight = 50;
  resetButtonX = width - resetButtonWidth - 20; // Margen derecho
  resetButtonY = height - resetButtonHeight - 20; // Margen inferior
  resetButtonColor = color(200, 100, 100); // Color del botón de reiniciar
  resetTextColor = color(255); // Color del texto del botón de reiniciar
  
  buttonFont = createFont("Times New Roman", 30);
  titleFont = createFont("Times New Roman Bold Italic", 56);
  
  ballX = width / 2;
  ballY = height / 2 - 100;
  ballSpeedX = 0;
  ballSpeedY = 5;
}

// Pantalla de documentacion
void drawDocumentation(){
  background(200, 220, 255);
  drawBackButton();
  textFont(buttonFont);
  textAlign(LEFT);
  fill(0);
  text("Documentacion en proceso", 50, 50);
}

// Pantalla de inicio animada
void drawStartScreen() {
    if (screenState == 0) {
    image(baseballField, 0, 0);
    drawPitcher();
    drawButton();
    drawDocButton();
    textAlign(CENTER,CENTER);
    textFont(titleFont);
    text("Flight Path", width/2, 50);
    if (pitching) {
      if (frameCounter % frameDelay == 0) {
        currentFrame++;
        if (currentFrame >= pitcherImages.length) {
          currentFrame = pitcherImages.length - 1;
        }
      }
      
      ballY += ballSpeedY;
      ballScale += 0.01;
      if (ballY >= height) {
        pitching = false;
        currentFrame = 0;
        screenState = 1;
        backgroundMusic1.stop();
      }
      drawBall();
      
      frameCounter++;
    }
  } else if (screenState == 1) {
    onStartScreen = false;
    backgroundMusic2.loop();
  }
}

// Simulación del proyectil
void draw() {
  if (onStartScreen) {
    drawStartScreen();
  } else {
    if (onDocumentation){
      drawDocumentation();
    }else{
    background(200, 220, 255);
    drawField();
    updateTrajectory();
    drawButtons();
    drawBackButton();
    drawSliders();
    drawIndicators();
  }
}
}
// Dibujar el campo
void drawField() {
  fill(50, 150, 50);
  rect(0, height - 100, width, 100);

  stroke(255);
  line(100, height - 100, width - 100, height - 100);
  line(100, height - 100, 100, height - 400);
}

void resetSimulation() {
    if (!xPositions.isEmpty()) {
    // Guardar la trayectoria actual antes de reiniciar
    allXPositions.add(new ArrayList<Float>(xPositions));
    allYPositions.add(new ArrayList<Float>(yPositions));
  }
  t = 0;
  xPositions.clear();
  yPositions.clear();

  // Usar los valores actualizados de los sliders para establecer las velocidades iniciales
  float v0Updated = velocidadSlider.getValue();
  float thetaUpdated = radians(anguloSlider.getValue());

  vx = v0Updated * cos(thetaUpdated);  // Velocidad horizontal inicial
  vy = v0Updated * sin(thetaUpdated);  // Velocidad vertical inicial

  // Agregar la posición inicial (x=0, y=h) al comenzar
  xPositions.add(0.0);
  yPositions.add(h);
  
  background(200, 220, 255);
  drawField();
}

void updateTrajectory() {
    // Dibujar todas las trayectorias anteriores
  for (int j = 0; j < allXPositions.size(); j++) {
    ArrayList<Float> trajX = allXPositions.get(j);
    ArrayList<Float> trajY = allYPositions.get(j);
    
    for (int i = 0; i < trajX.size() - 1; i++) {
      float x1 = 100 + trajX.get(i);
      float y1 = height - 100 - trajY.get(i);
      float x2 = 100 + trajX.get(i + 1);
      float y2 = height - 100 - trajY.get(i + 1);
      
      stroke(0, 0, 255);  // Color azul para trayectorias anteriores
      strokeWeight(1);
      line(x1, y1, x2, y2);
      
    }
  }
  
    if (startSimulation) {
    float v0Updated = velocidadSlider.getValue();
    float thetaUpdated = radians(anguloSlider.getValue());
    cd = resistenciaSlider.getValue();
    
    if (xPositions.size() == 0 || yPositions.size() == 0) {
      return;  // No hacer nada si no hay posiciones iniciales
    }

    float lastX = xPositions.get(xPositions.size() - 1);
    float lastY = yPositions.get(yPositions.size() - 1);

    if (cd == 0) {
      vy -= g * dt;
    } else {
      float ax = -cd * vx;
      float ay = -g - cd * vy;
      vx += ax * dt;
      vy += ay * dt;
    }

    float xNew = lastX + vx * dt;
    float yNew = lastY + vy * dt;
    xPositions.add(xNew);
    yPositions.add(yNew);
    t += dt;

    if (yNew <= 0) {
      startSimulation = false;
      
            // Guardar la trayectoria actual cuando el proyectil toque el suelo
      allXPositions.add(new ArrayList<Float>(xPositions));
      allYPositions.add(new ArrayList<Float>(yPositions));
    }

    for (int i = 0; i < xPositions.size() - 1; i++) {
      float x1 = 100 + xPositions.get(i);
      float y1 = height - 100 - yPositions.get(i);
      float x2 = 100 + xPositions.get(i + 1);
      float y2 = height - 100 - yPositions.get(i + 1);
      
      stroke(255, 0, 0);
      strokeWeight(2);
      line(x1, y1, x2, y2);
    }

    fill(255, 0, 0);
    noStroke();
    ellipse(100 + xNew, height - 100 - yNew, 15, 15);
  }
}

void drawPitcher() {
  float pitcherWidth = pitcherImages[currentFrame].width * pitcherScale;
  float pitcherHeight = pitcherImages[currentFrame].height * pitcherScale;
  float pitcherX = width / 2 - pitcherWidth / 2;
  float pitcherY = height / 2 - pitcherHeight / 1.2;
  image(pitcherImages[currentFrame], pitcherX, pitcherY, pitcherWidth, pitcherHeight);
}

void drawBall() {
  image(baseballImage, ballX - baseballImage.width * ballScale / 2, ballY - baseballImage.height * ballScale / 2, baseballImage.width * ballScale, baseballImage.height * ballScale);
}

void drawButton() {
  fill(buttonColor);
  rect(buttonX, buttonY, buttonWidth, buttonHeight, 10);
  
  fill(textColor);
  textFont(buttonFont);
  textAlign(CENTER, CENTER);
  text(buttonText, buttonX + buttonWidth / 2, buttonY + buttonHeight / 2);
}

void drawDocButton(){
  fill(buttonColor);
  rect(buttonDocX, buttonDocY, buttonDocWidth, buttonDocHeight, 10);
  
  fill(textColor);
  textFont(buttonFont);
  textAlign(CENTER, CENTER);
  text(buttonDocText, buttonDocX + buttonDocWidth / 2, buttonDocY + buttonDocHeight / 2);
}

void drawBackButton(){
 fill(buttonColor);
 rect(width - 170, 20, 150, 50, 10);
 
 fill(textColor);
 textFont(buttonFont);
 textAlign(CENTER, CENTER);
 text("Volver", width-170+150/2, 45);
}

// Dibujar botones de control
void drawButtons() {
  fill(0, 200, 0);
  rect(10, height - 130, 100, 30);
  fill(255);
  textSize(14);
  textAlign(CENTER, CENTER);
  text("Iniciar", 10 + 100 / 2, height - 130 + 30 / 2);

  fill(200, 0, 0);
  rect(120, height - 130, 100, 30);
  fill(255);
  text("Detener", 120 + 100 / 2, height - 130 + 30 / 2);
  
    // Dibuja el botón de reiniciar
  fill(resetButtonColor);
  rect(resetButtonX, resetButtonY, resetButtonWidth, resetButtonHeight, 10);
  fill(resetTextColor);
  textSize(14);
  text("Reiniciar", resetButtonX + resetButtonWidth / 2, resetButtonY + resetButtonHeight / 2);
}

// Dibujar sliders para controlar velocidad, ángulo y resistencia
void drawSliders() {
  velocidadSlider.display();
  anguloSlider.display();
  resistenciaSlider.display();
  
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Velocidad (m/s)", velocidadSlider.x + velocidadSlider.w / 2, velocidadSlider.y - 10);
  text("Ángulo (°)", anguloSlider.x + anguloSlider.w / 2, anguloSlider.y - 10);
  text("Resistencia", resistenciaSlider.x + resistenciaSlider.w / 2, resistenciaSlider.y - 10);
}

// Dibujar indicadores para mostrar parámetros actuales
void drawIndicators() {
  fill(0);
  textAlign(LEFT);
  textSize(20);
  text("Velocidad inicial: " + nf(velocidadSlider.getValue(), 1, 2) + " m/s", 10, 30);
  text("Ángulo: " + nf(anguloSlider.getValue(), 1, 2) + "°", 10, 50);
  text("Resistencia del aire: " + nf(resistenciaSlider.getValue(), 1, 2), 10, 70);
  text("Tiempo de vuelo: " + nf(t, 1, 2) + " s", 10, 90);
}



// Manejo de clics de mouse
void mousePressed() {
  if (onStartScreen) {
    
    if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight) {
      if (screenState == 0) {
        pitching = true;
        ballY = height / 2 - 100;
        ballScale = 0.005;
        currentFrame = 0;
        frameCounter = 0;
        startSound.play();
        buttonstart.play();
      }
    }
      if(mouseX > buttonDocX && mouseX < buttonDocX + buttonDocWidth && mouseY > buttonDocY && mouseY < buttonDocY + buttonDocHeight){
      onDocumentation = true;
      onStartScreen = false;
    }
  } else {
    if(onDocumentation){
    if(mouseX>width-170 && mouseX < width-20 && mouseY > 20 && mouseY < 70){
    onDocumentation = false;
    onStartScreen = true;
    }
    }else{
    if(mouseX>width-170 && mouseX < width-20 && mouseY > 20 && mouseY < 70){
      onStartScreen = true;
      screenState = 0;
      pitching = false;
      backgroundMusic2.stop(); // Detener la música de fondo de la simulación
      backgroundMusic1.loop(); // Reproducir la música de la pantalla de inicio
    }
    // Iniciar o detener simulación según el botón presionado
    if (mouseX > 10 && mouseX < 10 + 100 && mouseY > height - 130 && mouseY < height - 130 + 30) {
      startSimulation = true;  // Inicia la simulación
      backgroundMusic1.stop();
      resetSimulation();
      buttonstart.play();
    }
    if (mouseX > 120 && mouseX < 120 + 100 && mouseY > height - 130 && mouseY < height - 130 + 30) {
      startSimulation = false;
      buttonstop.play();
    }
        // Reiniciar la simulación
    if (mouseX > resetButtonX && mouseX < resetButtonX + resetButtonWidth && mouseY > resetButtonY && mouseY < resetButtonY + resetButtonHeight) {
      resetAll(); // Función para reiniciar la simulación
    }


    mousePressedSlider();
  }
}
}
// Nueva función para reiniciar la simulación
void resetAll() {
  // Limpiar trayectorias anteriores
  allXPositions.clear();
  allYPositions.clear();
  
  // Reiniciar las posiciones y parámetros
  resetSimulations();
}

// Función que se mantiene para reiniciar la simulación
void resetSimulations() {
  if (!xPositions.isEmpty()) {
    // Guardar la trayectoria actual antes de reiniciar
    allXPositions.add(new ArrayList<Float>(xPositions));
    allYPositions.add(new ArrayList<Float>(yPositions));
  }
  t = 0;
  xPositions.clear();
  yPositions.clear();


}

class Slider {
  float x, y, w, h;
  float minVal, maxVal;
  float val;
  boolean dragging = false;

  Slider(float x_, float y_, float w_, float h_, float min_, float max_, float val_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    minVal = min_;
    maxVal = max_;
    val = val_;
  }

  void display() {
    fill(150);
    rect(x, y, w, h);
    fill(255, 0, 0);
    float xpos = map(val, minVal, maxVal, x, x + w);
    ellipse(xpos, y + h / 2, 15, 15);
  }

  void update() {
    if (dragging) {
      val = map(constrain(mouseX, x, x + w), x, x + w, minVal, maxVal); 
    }
  }

  float getValue() {
    return val;
  }
}

// Manejo de sliders cuando se arrastran con el mouse
void mouseDragged() {
  if (velocidadSlider.dragging) velocidadSlider.update();
  if (anguloSlider.dragging) anguloSlider.update();
  if (resistenciaSlider.dragging) resistenciaSlider.update();
}

void mouseReleased() {
  velocidadSlider.dragging = false;
  anguloSlider.dragging = false;
  resistenciaSlider.dragging = false;
}

// Verificar si se hace clic en algún slider para activarlo
void mousePressedSlider() {
  if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight) {
    if (screenState == 0) {
      pitching = true;
      ballY = height / 2 - 100;
      ballScale = 0.005;
      currentFrame = 0;
      frameCounter = 0;
    }
  }

  if (mouseX > velocidadSlider.x && mouseX < velocidadSlider.x + velocidadSlider.w &&
      mouseY > velocidadSlider.y && mouseY < velocidadSlider.y + velocidadSlider.h) {
    velocidadSlider.dragging = true;
  }
  if (mouseX > anguloSlider.x && mouseX < anguloSlider.x + anguloSlider.w &&
      mouseY > anguloSlider.y && mouseY < anguloSlider.y + anguloSlider.h) {
    anguloSlider.dragging = true;
  }
  if (mouseX > resistenciaSlider.x && mouseX < resistenciaSlider.x + resistenciaSlider.w &&
      mouseY > resistenciaSlider.y && mouseY < resistenciaSlider.y + resistenciaSlider.h) {
    resistenciaSlider.dragging = true;
  }
}
