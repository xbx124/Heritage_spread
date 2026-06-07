package org.example.heritage.common.interceptor;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.result.Result;
import org.example.heritage.common.utils.JwtUtil;
import org.springframework.http.HttpMethod;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class JwtInterceptor implements HandlerInterceptor {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public boolean preHandle(@NonNull HttpServletRequest request,
                             @NonNull HttpServletResponse response,
                             @Nullable Object handler) throws Exception {

        if (isPublicRequest(request)) {
            return true;
        }

        String token = request.getHeader("Authorization");

        if (token == null || token.isBlank()) {
            writeUnauthorized(response, "未登录");
            return false;
        }

        try {
            if (token.startsWith("Bearer ")) {
                token = token.substring(7);
            }

            DecodedJWT jwt = JwtUtil.verify(token);

            Long userId = jwt.getClaim("userId").asLong();
            String username = jwt.getClaim("username").asString();
            String role = jwt.getClaim("role").asString();

            UserContext.setCurrentUserId(userId);
            UserContext.setCurrentUsername(username);
            UserContext.setCurrentRole(role);

            return true;

        } catch (Exception e) {
            writeUnauthorized(response, "Token无效或已过期");
            return false;
        }
    }

    /**
     * Spring MVC 的 excludePathPatterns 不能区分 GET/POST/PUT/DELETE，
     * 所以公共查询接口统一在拦截器内部按请求方式和路径精准放行。
     */
    private boolean isPublicRequest(HttpServletRequest request) {
        String method = request.getMethod();
        String path = request.getRequestURI();
        String contextPath = request.getContextPath();
        if (contextPath != null && !contextPath.isBlank() && path.startsWith(contextPath)) {
            path = path.substring(contextPath.length());
        }

        if ("/api/auth/login".equals(path) || "/api/auth/register".equals(path)) {
            return true;
        }

        if (isKnife4jOrSystemPath(path)) {
            return true;
        }
        if (HttpMethod.OPTIONS.matches(method)) {
            return true;
        }
        if (!HttpMethod.GET.matches(method)) {
            return false;
        }

        return "/api/search".equals(path)
                || "/api/categories".equals(path)
                || "/api/projects".equals(path)
                || path.matches("^/api/projects/[^/]+$")
                || "/api/news".equals(path)
                || path.matches("^/api/news/[^/]+$")
                || path.matches("^/api/news/[^/]+/comments$")
                || "/api/stats/channel".equals(path)
                || "/api/stats/project".equals(path)
                || path.matches("^/api/stats/project/[^/]+$")
                || path.matches("^/api/stats/project/[^/]+/trend$");
    }

    private boolean isKnife4jOrSystemPath(String path) {
        return path.startsWith("/webjars/")
                || "/doc.html".equals(path)
                || path.startsWith("/swagger-ui/")
                || path.startsWith("/v3/api-docs")
                || "/error".equals(path);
    }

    private void writeUnauthorized(HttpServletResponse response, String message) throws Exception {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(
                objectMapper.writeValueAsString(Result.error(401, message))
        );
    }

    @Override
    public void afterCompletion(@NonNull HttpServletRequest request,
                                @NonNull HttpServletResponse response,
                                @Nullable Object handler,
                                Exception ex) {

        UserContext.clear();
    }
}
