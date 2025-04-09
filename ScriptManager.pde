class ScriptManager {
  Interpreter bsh;

  // Swing UI components (fully qualified)
  javax.swing.JFrame consoleFrame;
  javax.swing.JTextArea scriptArea;
  javax.swing.JButton runButton;

  ScriptManager() {
    initInterpreter();
    initConsole();
  }



  // Initialize BeanShell and expose desired variables
  void initInterpreter() {
    bsh = new Interpreter();
    try {

      // Relax Java access rules to allow non‑public methods
      bsh.setStrictJava(false);

      // Enable general accessibility for private fields (doesn't work for methods)
      bsh.eval("setAccessibility(true);");

      // Expose your sketch variables here; adjust as needed:
      bsh.set("lines", lines);
      bsh.set("multiSelectedLines", multiSelectedLines);
      bsh.set("selectedLine", selectedLine);
      bsh.set("lineManager", lineManager);

      // Importing necessary classes for convenience
      bsh.eval("import java.util.*;");
      bsh.eval("import java.util.concurrent.CopyOnWriteArrayList;");
      bsh.eval("import " + Line.class.getCanonicalName() + ";");  // Ensure Line is recognized
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }


  // Initialize a Swing console window with a resizable text area and run button
  void initConsole() {
    consoleFrame = new javax.swing.JFrame("Script Console");
    consoleFrame.setDefaultCloseOperation(javax.swing.JFrame.HIDE_ON_CLOSE);

    // Create a multi-line text area with scrollbars
    scriptArea = new javax.swing.JTextArea(15, 50);
    scriptArea.setFont(new java.awt.Font("Monospaced", java.awt.Font.PLAIN, 14));
    javax.swing.JScrollPane scrollPane = new javax.swing.JScrollPane(scriptArea);

    // Create a run button to execute the script
    runButton = new javax.swing.JButton("Run Code");
    runButton.setFont(new java.awt.Font("Arial", java.awt.Font.BOLD, 14));
    runButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent e) {
        executeCode();
      }
    }
    );

    // Layout: use fully qualified BorderLayout and JPanel
    javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.BorderLayout());
    panel.add(scrollPane, java.awt.BorderLayout.CENTER);
    panel.add(runButton, java.awt.BorderLayout.SOUTH);

    consoleFrame.getContentPane().add(panel);
    consoleFrame.pack();
    consoleFrame.setLocationRelativeTo(null);
    // Initially hidden—toggle it from your sketch when needed.
    consoleFrame.setVisible(false);
  }

  // Evaluate the code entered in the text area using BeanShell
  void executeCode() {
    initInterpreter();
    String code = scriptArea.getText();
    try {
      bsh.eval(code);
    }
    catch(Exception e) {
      e.printStackTrace();
      javax.swing.JOptionPane.showMessageDialog(consoleFrame,
        "Error: " + e.getMessage(), "Script Error", javax.swing.JOptionPane.ERROR_MESSAGE);
    }
  }


  // Toggle the visibility of the script console
  void toggleVisibility() {
    consoleFrame.setVisible(!consoleFrame.isVisible());
  }
}
