package com.pm.authservice.service;

import com.pm.authservice.model.User;
import com.pm.authservice.repository.UserRepository;
import java.util.Optional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;

  public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
    this.userRepository = userRepository;
    this.passwordEncoder = passwordEncoder;
  }

  public Optional<User> findByEmail(String email) {
    return userRepository.findByEmail(email);
  }

  public User createUser(String email, String password, String role) {
    User user = new User();
    user.setEmail(email);
    user.setPassword(passwordEncoder.encode(password));
    user.setRole(role);
    return userRepository.save(user);
  }

  public boolean existsByEmail(String email) {
    return userRepository.findByEmail(email).isPresent();
  }

  public void updatePassword(String email, String newPassword) {
    User user = userRepository.findByEmail(email)
        .orElseThrow(() -> new com.pm.authservice.exception.UserNotFoundException(
            "User not found with email: " + email));
    user.setPassword(passwordEncoder.encode(newPassword));
    userRepository.save(user);
  }

  public void changePassword(String email, String currentPassword, String newPassword) {
    User user = userRepository.findByEmail(email)
        .orElseThrow(() -> new com.pm.authservice.exception.UserNotFoundException(
            "User not found"));
    if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
      throw new com.pm.authservice.exception.InvalidPasswordException(
          "Current password is incorrect");
    }
    user.setPassword(passwordEncoder.encode(newPassword));
    userRepository.save(user);
  }
}
