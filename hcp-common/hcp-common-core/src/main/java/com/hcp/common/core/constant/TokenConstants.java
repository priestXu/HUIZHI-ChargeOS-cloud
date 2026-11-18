package com.hcp.common.core.constant;

/**
 * Token的Key常量
 *
 * @author vctgo
 */
public class TokenConstants
{
    /**
     * 令牌自定义标识
     */
    public static final String AUTHENTICATION = "Authorization";

    /**
     * 令牌前缀
     */
    public static final String PREFIX = "Bearer ";

    /**
     * 令牌秘钥
     *
     * CHG-001 D4：jjwt 0.12.x 的 HS512 要求密钥不少于 64 字节，原 26 字节密钥会导致
     * io.jsonwebtoken.security.WeakKeyException。生产环境必须通过外部配置覆盖此开发默认值。
     */
    public final static String SECRET = "hcp-chargeos-jwt-hmac-sha512-dev-default-key-change-me-in-production-2026";

}
