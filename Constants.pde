// Constants.pde
static class Constants {
    static final int GRID_SIZE = 50;
    static final int MAX_ENTITIES = 50;
    static final int MAX_HISTORY = 50;
    
    static final int TYPE_NODE = 0;
    static final int TYPE_DATA = 1;
    
    // Theme constants
    static final int THEME_DARK = 0;
    static final int THEME_LIGHT = 1;
    static final int THEME_MIDNIGHT = 2;
    static final int THEME_MONOCHROME = 3;
    static final int THEME_NORDIC = 4;
    static final int THEME_SOLARIZED = 5;
    static final int THEME_MINIMAL_GREEN = 6;
    
    // Theme names
    static final String[] THEME_NAMES = {
        "Dark", "Light", "Midnight","Mono Chrome", "Nordic", "Solarized", "Minimal Green"
    };
}

class ColorScheme {
    int backgroundColor;
    int gridColor;
    int nodeColor;
    int dataNodeColor;
    int connectionColor;
    int flowColor;
    int textColor;
    int textColorEntity;
    int highlightColor;
    int panelBackgroundColor;
    int accentColor;
    
    ColorScheme(int bg, int grid, int node, int dataNode, int conn, 
               int flow, int text, int textEntity, int highlight, int panel, int accent) {
        backgroundColor = bg;
        gridColor = grid;
        nodeColor = node;
        dataNodeColor = dataNode;
        connectionColor = conn;
        flowColor = flow;
        textColor = text;
        textColorEntity = textEntity;
        highlightColor = highlight;
        panelBackgroundColor = panel;
        accentColor = accent;
    }
}
