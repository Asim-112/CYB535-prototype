package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class AppTest {

    @Test
    void greetWithName() {
        assertEquals("Hello, Alice!", App.greet("Alice"));
    }

    @Test
    void greetWithNull() {
        assertEquals("Hello, World!", App.greet(null));
    }

    @Test
    void greetWithEmptyString() {
        assertEquals("Hello, World!", App.greet(""));
    }

    @Test
    void greetWithBlankString() {
        assertEquals("Hello, World!", App.greet("   "));
    }

    @Test
    void appCanBeInstantiated() {
        App app = new App();
        assertNotNull(app);
    }
}
