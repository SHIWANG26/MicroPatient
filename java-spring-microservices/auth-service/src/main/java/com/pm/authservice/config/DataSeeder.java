package com.pm.authservice.config;

import com.pm.authservice.model.User;
import com.pm.authservice.repository.UserRepository;
import java.util.Optional;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Seeds the test user with a properly BCrypt-encoded password on startup.
 * Ensures login works regardless of data.sql format.
 */
@Component
public class DataSeeder implements CommandLineRunner {

  private static final String TEST_EMAIL = "testuser@test.com";
  private static final String TEST_PASSWORD = "password1234";

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;

  public DataSeeder(UserRepository userRepository, PasswordEncoder passwordEncoder) {
    this.userRepository = userRepository;
    this.passwordEncoder = passwordEncoder;
  }

  @Override
  public void run(String... args) {
    Optional<User> existing = userRepository.findByEmail(TEST_EMAIL);
    if (existing.isEmpty()) {
      User user = new User();
      user.setEmail(TEST_EMAIL);
      user.setPassword(passwordEncoder.encode(TEST_PASSWORD));
      user.setRole("ADMIN");
      userRepository.save(user);
    } else {
      // Ensure password hash is valid BCrypt (in case data.sql had wrong format)
      User u = existing.get();
      if (!passwordEncoder.matches(TEST_PASSWORD, u.getPassword())) {
        u.setPassword(passwordEncoder.encode(TEST_PASSWORD));
        userRepository.save(u);
      }
    }
  }
}
