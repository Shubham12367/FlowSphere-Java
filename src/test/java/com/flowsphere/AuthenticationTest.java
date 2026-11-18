package com.flowsphere;

import com.flowsphere.entity.AccountStatus;
import com.flowsphere.entity.RoleName;
import com.flowsphere.entity.User;
import com.flowsphere.service.CustomUserDetailsService;
import com.flowsphere.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AuthenticationTest {

    @Autowired
    private UserService userService;

    @Autowired
    private CustomUserDetailsService customUserDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Test
    @Transactional
    void testUserRegistrationAndAuthentication() {
        String testEmail = "testuser." + System.currentTimeMillis() + "@flowsphere.local";
        String rawPassword = "SecurePassword@123";

        // Register user
        User user = userService.registerUser(testEmail, rawPassword, "Jane", "Doe", null);
        assertNotNull(user.getId());
        assertEquals(testEmail.toLowerCase(), user.getEmail());
        assertEquals(AccountStatus.ACTIVE, user.getStatus());
        assertTrue(passwordEncoder.matches(rawPassword, user.getPasswordHash()));

        // Default role should be EMPLOYEE
        assertTrue(user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.EMPLOYEE));

        // Load via UserDetailsService
        UserDetails userDetails = customUserDetailsService.loadUserByUsername(testEmail);
        assertEquals(testEmail.toLowerCase(), userDetails.getUsername());
        assertTrue(userDetails.isEnabled());
        assertTrue(userDetails.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_EMPLOYEE")));

        // Duplicate registration should throw exception
        assertThrows(IllegalArgumentException.class, () -> {
            userService.registerUser(testEmail, "AnotherPassword@123", "Duplicate", "User", null);
        });
    }

    @Test
    void testPasswordEncoderStrength() {
        String raw = "Admin@123";
        String encoded = passwordEncoder.encode(raw);
        assertNotNull(encoded);
        assertTrue(encoded.startsWith("$2a$") || encoded.startsWith("$2b$") || encoded.startsWith("$2y$"));
        assertTrue(passwordEncoder.matches(raw, encoded));
    }
}
