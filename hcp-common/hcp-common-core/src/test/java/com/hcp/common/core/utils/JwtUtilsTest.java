package com.hcp.common.core.utils;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.HashMap;
import java.util.Map;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.hcp.common.core.constant.SecurityConstants;
import com.hcp.common.core.constant.TokenConstants;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;

/**
 * JwtUtils 回归测试（CHG-001 T05-3 / D8）
 *
 * 锁定 jjwt 0.12.x 升级后的签名与校验行为，防止密钥长度或 API 再次回退。
 */
class JwtUtilsTest
{
    @Test
    @DisplayName("HS512 密钥长度必须 >= 64 字节，否则 jjwt 会抛 WeakKeyException")
    void secretMustBeLongEnoughForHs512()
    {
        assertTrue(TokenConstants.SECRET.getBytes(java.nio.charset.StandardCharsets.UTF_8).length >= 64,
                "TokenConstants.SECRET 必须不少于 64 字节");
    }

    @Test
    @DisplayName("签发后可原样解析出相同的声明")
    void createAndParseTokenRoundTrip()
    {
        Map<String, Object> claims = new HashMap<>();
        claims.put(SecurityConstants.USER_KEY, "user-key-1");
        claims.put(SecurityConstants.DETAILS_USER_ID, "1001");
        claims.put(SecurityConstants.DETAILS_USERNAME, "admin");
        claims.put(SecurityConstants.DETAILS_DEPT_ID, "103");

        String token = JwtUtils.createToken(claims);
        assertNotNull(token);

        Claims parsed = JwtUtils.parseToken(token);
        assertEquals("user-key-1", JwtUtils.getValue(parsed, SecurityConstants.USER_KEY));
        assertEquals("1001", JwtUtils.getUserId(token));
        assertEquals("admin", JwtUtils.getUserName(token));
        assertEquals("103", JwtUtils.getDeptId(token));
    }

    @Test
    @DisplayName("被篡改的令牌必须校验失败")
    void tamperedTokenIsRejected()
    {
        Map<String, Object> claims = new HashMap<>();
        claims.put(SecurityConstants.DETAILS_USERNAME, "admin");
        String token = JwtUtils.createToken(claims);

        int dot = token.lastIndexOf('.');
        char last = token.charAt(token.length() - 1);
        String tampered = token.substring(0, dot + 1) + (last == 'A' ? 'B' : 'A');

        assertThrows(JwtException.class, () -> JwtUtils.parseToken(tampered));
    }
}
