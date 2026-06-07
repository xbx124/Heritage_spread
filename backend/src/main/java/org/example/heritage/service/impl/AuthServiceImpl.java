package org.example.heritage.service.impl;

import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.common.utils.JwtUtil;
import org.example.heritage.common.utils.PasswordUtil;
import org.example.heritage.mapper.SysUserMapper;
import org.example.heritage.pojo.dto.LoginDTO;
import org.example.heritage.pojo.dto.RegisterDTO;
import org.example.heritage.pojo.entity.SysUser;
import org.example.heritage.pojo.vo.LoginVO;
import org.example.heritage.pojo.vo.UserVO;
import org.example.heritage.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private SysUserMapper sysUserMapper;

    @Override
    public SysUser register(RegisterDTO dto) {
        SysUser exist = sysUserMapper.selectByUsername(dto.getUsername());
        if (exist != null) {
            throw new BusinessException(409, "用户名已存在");
        }

        String role = dto.getRole();
        if (!RoleConstants.ADMIN.equals(role)
                && !RoleConstants.EDITOR.equals(role)
                && !RoleConstants.USER.equals(role)) {
            role = RoleConstants.USER;
        }

        SysUser user = new SysUser();
        user.setUsername(dto.getUsername());
        user.setPassword(PasswordUtil.encode(dto.getPassword()));
        user.setRole(role);
        user.setStatus(1);
        LocalDateTime now = LocalDateTime.now();
        user.setCreateTime(now);
        user.setUpdateTime(now);

        sysUserMapper.insert(user);

        return user;
    }

    @Override
    public LoginVO login(LoginDTO dto) {
        SysUser user = sysUserMapper.selectByUsername(dto.getUsername());
        if (user == null || !PasswordUtil.matches(dto.getPassword(), user.getPassword())) {
            throw new BusinessException(401, "用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BusinessException(403, "账号已被禁用");
        }

        String token = JwtUtil.createToken(
                user.getUserId().longValue(),
                user.getUsername(),
                user.getRole()
        );
        LoginVO vo = new LoginVO();
        vo.setToken(token);
        vo.setUser(buildUserVO(user));
        return vo;
    }

    @Override
    public UserVO getCurrentUser() {
        Long userId = UserContext.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException(401, "未登录");
        }

        SysUser user = sysUserMapper.selectById(userId.intValue());
        if (user == null) {
            throw new BusinessException(404, "用户不存在");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BusinessException(403, "账号已被禁用");
        }

        return buildUserVO(user);
    }

    private UserVO buildUserVO(SysUser user) {
        UserVO vo = new UserVO();
        vo.setUserId(user.getUserId());
        vo.setUsername(user.getUsername());
        vo.setRole(user.getRole());
        vo.setStatus(user.getStatus());
        vo.setCreateTime(user.getCreateTime());
        return vo;
    }
}
