package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.dto.LoginDTO;
import org.example.heritage.pojo.dto.RegisterDTO;
import org.example.heritage.pojo.entity.SysUser;
import org.example.heritage.pojo.vo.LoginVO;
import org.example.heritage.pojo.vo.UserVO;
import org.example.heritage.service.AuthService;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

@Tag(name = "认证模块")
@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "用户注册")
    @PostMapping("/register")
    public Result<UserVO> register(@Valid @RequestBody RegisterDTO dto) {
        log.info("用户注册开始，username={}, role={}", dto.getUsername(), dto.getRole());
        SysUser user = authService.register(dto);
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user,vo);
        log.info("用户注册成功，userId={}, username={}", vo.getUserId(), vo.getUsername());
        return Result.success(vo);
    }

    @Operation(summary = "用户登录")
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        log.info("用户登录开始，username={}", dto.getUsername());
        LoginVO vo = authService.login(dto);
        log.info("用户登录成功，username={}", vo.getUser().getUsername());
        return Result.success(vo);
    }

    @Operation(summary = "获取当前登录用户")
    @GetMapping("/me")
    public Result<UserVO> me() {
        log.info("获取当前登录用户开始");
        UserVO vo = authService.getCurrentUser();
        log.info("获取当前登录用户成功，userId={}, username={}", vo.getUserId(), vo.getUsername());
        return Result.success(vo);
    }
}
