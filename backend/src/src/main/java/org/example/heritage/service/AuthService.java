package org.example.heritage.service;

import org.example.heritage.pojo.dto.LoginDTO;
import org.example.heritage.pojo.dto.RegisterDTO;
import org.example.heritage.pojo.entity.SysUser;
import org.example.heritage.pojo.vo.LoginVO;
import org.example.heritage.pojo.vo.UserVO;

public interface AuthService {

    SysUser register(RegisterDTO dto);

    LoginVO login(LoginDTO dto);

    UserVO getCurrentUser();
}