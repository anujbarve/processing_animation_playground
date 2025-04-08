// Main.pde
Application app;

void setup() {
    fullScreen();
    frameRate(60);
    app = new Application();
}

void draw() {
    app.update();
    app.draw();
}

void keyPressed() {
    // Modified to match InputHandler method signature
    app.getInputHandler().handleKeyPressed(key, keyCode, keyEvent);
}

void mousePressed() {
    // Modified to match InputHandler method signature
    app.getInputHandler().handleMousePressed(mouseX, mouseY);
}

void mouseReleased() {
    // Modified to match InputHandler method signature
    app.getInputHandler().handleMouseReleased(mouseX, mouseY);
}
