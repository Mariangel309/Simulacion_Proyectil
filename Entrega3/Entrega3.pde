float v0 = 60; // Velocidad inicial
float theta = radians(60); // Ángulo de lanzamiento
float g = 9.8; // Gravedad
float h = 50; // Altura inicial
float t = 0; // Tiempo
float dt = 0.1; // Incremento de tiempo
float airResistance = 0; // Resistencia del aire

ArrayList<Float> xPositions = new ArrayList<Float>();  
ArrayList<Float> yPositions = new ArrayList<Float>();

boolean startSimulation = false;
boolean onStartScreen = true;

PFont font;

// Controles de la interfaz
Slider velocidadSlider, anguloSlider, resistenciaSlider;

void setup() {
  size(800, 600);
  font = createFont("Arial", 16, true);
  textFont(font);
  background(200, 220, 255);
  frameRate(60);
  
  // Inicialización de sliders
  velocidadSlider = new Slider(50, height - 160, 150, 20, 0, 100, v0);
  anguloSlider = new Slider(250, height - 160, 150, 20, 0, 90, degrees(theta));
  resistenciaSlider = new Slider(450, height - 160, 150, 20, 0, 1, airResistance);
}

// Pantalla de inicio animada
void drawStartScreen() {
  background(50, 150, 255);
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Flight Path", width / 2, height / 3);
  
  fill(255, 100, 100, 150);
  ellipse(width / 2 + sin(frameCount * 0.1) * 100, height / 2, 80, 80);
  
  fill(0);
  textSize(20);
  text("Haz clic para iniciar", width / 2, height / 1.5);
}

// Simulación del proyectil
void draw() {
  if (onStartScreen) {
    drawStartScreen();
  } else {
    background(200, 220, 255);
    drawField();
    updateTrajectory();
    drawButtons();
    drawSliders();
    drawIndicators();
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

// Actualizar trayectoria del proyectil
void updateTrajectory() {
  if (startSimulation) {
    float v0Updated = velocidadSlider.getValue();
    float thetaUpdated = radians(anguloSlider.getValue());
    airResistance = resistenciaSlider.getValue();
    
    float xNew = (v0Updated * cos(thetaUpdated) - airResistance * t) * t;
    float yNew = h + (v0Updated * sin(thetaUpdated) * t - 0.5 * g * t * t);
    
    fill(255, 0, 0);
    noStroke();
    ellipse(100 + xNew, height - 100 - yNew, 15, 15);
    
    xPositions.add(100 + xNew);
    yPositions.add(height - 100 - yNew);
    
    t += dt; // Incrementar tiempo
    
    if (height - 100 - yNew >= height - 100) {
      startSimulation = false;
    }
  }
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
}

// Dibujar sliders para controlar velocidad, ángulo y resistencia
void drawSliders() {
  velocidadSlider.display();
  anguloSlider.display();
  resistenciaSlider.display();
  
  fill(0);
  textAlign(CENTER, CENTER);
  text("Velocidad (m/s)", velocidadSlider.x + velocidadSlider.w / 2, velocidadSlider.y - 10);
  text("Ángulo (°)", anguloSlider.x + anguloSlider.w / 2, anguloSlider.y - 10);
  text("Resistencia", resistenciaSlider.x + resistenciaSlider.w / 2, resistenciaSlider.y - 10);
}

// Dibujar indicadores para mostrar parámetros actuales
void drawIndicators() {
  fill(0);
  textAlign(LEFT);
  text("Velocidad inicial: " + nf(velocidadSlider.getValue(), 1, 2) + " m/s", 10, 30);
  text("Ángulo: " + nf(anguloSlider.getValue(), 1, 2) + "°", 10, 50);
  text("Resistencia del aire: " + nf(resistenciaSlider.getValue(), 1, 2), 10, 70);
  text("Tiempo de vuelo: " + nf(t, 1, 2) + " s", 10, 90);
}

// Reiniciar la simulación
void resetSimulation() {
  t = 0;
  xPositions.clear();
  yPositions.clear();
  background(200, 220, 255);
  drawField();
}

// Manejo de clics de mouse
void mousePressed() {
  if (onStartScreen) {
    onStartScreen = false;
  } else {
    // Iniciar o detener simulación según el botón presionado
    if (mouseX > 10 && mouseX < 10 + 100 && mouseY > height - 130 && mouseY < height - 130 + 30) {
      startSimulation = true;  // Inicia la simulación
      resetSimulation();
    }
    if (mouseX > 120 && mouseX < 120 + 100 && mouseY > height - 130 && mouseY < height - 130 + 30) {
      startSimulation = false;
    }


    mousePressedSlider();
  }
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
