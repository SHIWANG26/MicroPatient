package com.pm.authservice.service;

import com.pm.authservice.dto.ChangePasswordRequestDTO;
import com.pm.authservice.dto.ForgotPasswordRequestDTO;
import com.pm.authservice.dto.LoginRequestDTO;
import com.pm.authservice.dto.RegisterRequestDTO;
import com.pm.authservice.exception.EmailAlreadyExistsException;
import com.pm.authservice.exception.UserNotFoundException;
import com.pm.authservice.model.User;
import com.pm.authservice.util.JwtUtil;
import io.jsonwebtoken.JwtException;
import java.util.Optional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  private final UserService userService;
  private final PasswordEncoder passwordEncoder;
  private final JwtUtil jwtUtil;

  public AuthService(UserService userService, PasswordEncoder passwordEncoder,
      JwtUtil jwtUtil) {
    this.userService = userService;
    this.passwordEncoder = passwordEncoder;
    this.jwtUtil = jwtUtil;
  }

  public void forgotPassword(ForgotPasswordRequestDTO request) {
    if (!userService.existsByEmail(request.getEmail())) {
      throw new UserNotFoundException("No account found with this email");
    }
    userService.updatePassword(request.getEmail(), request.getNewPassword());
  }

  public void changePassword(String token, ChangePasswordRequestDTO request) {
    String email = jwtUtil.getEmailFromToken(token);
    userService.changePassword(email, request.getCurrentPassword(),
        request.getNewPassword());
  }

  public String register(RegisterRequestDTO registerRequestDTO) {
    if (userService.existsByEmail(registerRequestDTO.getEmail())) {
      throw new EmailAlreadyExistsException(
          "A user with this email already exists");
    }
    User user = userService.createUser(
        registerRequestDTO.getEmail(),
        registerRequestDTO.getPassword(),
        "USER");
    return jwtUtil.generateToken(user.getEmail(), user.getRole());
  }

  public Optional<String> authenticate(LoginRequestDTO loginRequestDTO) {
    Optional<String> token = userService.findByEmail(loginRequestDTO.getEmail())
        .filter(u -> passwordEncoder.matches(loginRequestDTO.getPassword(),
            u.getPassword()))
        .map(u -> jwtUtil.generateToken(u.getEmail(), u.getRole()));

    return token;
  }

  public boolean validateToken(String token) {
    try {
      jwtUtil.validateToken(token);
      return true;
    } catch (JwtException e){
      return false;
    }
  }
}
