package com.hcp.common.swagger.config;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;

/**
 * OpenAPI 3 / Knife4j 自动配置
 *
 * CHG-001 T03-1：由 springfox（Swagger2）迁移至 springdoc OpenAPI 3。
 * 原 SwaggerBeanPostProcessor（springfox PathPattern 修补）与 SwaggerWebConfiguration
 * （springfox 静态资源映射）已不再需要，随 springfox 一并移除。
 *
 * @author vctgo
 */
@Configuration
@EnableConfigurationProperties(SwaggerProperties.class)
@ConditionalOnProperty(name = "swagger.enabled", matchIfMissing = true)
public class SwaggerAutoConfiguration
{
    /**
     * 默认的排除路径，排除Spring Boot默认的错误处理路径和端点
     */
    private static final List<String> DEFAULT_EXCLUDE_PATH = Arrays.asList("/error", "/actuator/**");

    private static final String BASE_PATH = "/**";

    /** 全局鉴权方案名称，与请求头 Authorization 保持一致 */
    private static final String SECURITY_SCHEME_NAME = "Authorization";

    @Bean
    public OpenAPI hcpOpenApi(SwaggerProperties swaggerProperties)
    {
        SwaggerProperties.Contact contact = swaggerProperties.getContact();
        Info info = new Info()
                .title(swaggerProperties.getTitle())
                .description(swaggerProperties.getDescription())
                .version(swaggerProperties.getVersion())
                .termsOfService(swaggerProperties.getTermsOfServiceUrl())
                .contact(new Contact()
                        .name(contact == null ? null : contact.getName())
                        .url(contact == null ? null : contact.getUrl())
                        .email(contact == null ? null : contact.getEmail()));

        if (swaggerProperties.getLicense() != null && !swaggerProperties.getLicense().isEmpty())
        {
            info.license(new License()
                    .name(swaggerProperties.getLicense())
                    .url(swaggerProperties.getLicenseUrl()));
        }

        // 安全模式：token 通过 Authorization 请求头传递
        Components components = new Components().addSecuritySchemes(SECURITY_SCHEME_NAME,
                new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")
                        .in(SecurityScheme.In.HEADER)
                        .name(SECURITY_SCHEME_NAME));

        return new OpenAPI()
                .info(info)
                .components(components)
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME));
    }

    @Bean
    public GroupedOpenApi hcpGroupedOpenApi(SwaggerProperties swaggerProperties)
    {
        // base-path 处理
        if (swaggerProperties.getBasePath().isEmpty())
        {
            swaggerProperties.getBasePath().add(BASE_PATH);
        }
        // exclude-path 处理
        if (swaggerProperties.getExcludePath().isEmpty())
        {
            swaggerProperties.getExcludePath().addAll(DEFAULT_EXCLUDE_PATH);
        }

        GroupedOpenApi.Builder builder = GroupedOpenApi.builder()
                .group("hcp")
                .pathsToMatch(swaggerProperties.getBasePath().toArray(new String[0]))
                .pathsToExclude(swaggerProperties.getExcludePath().toArray(new String[0]));

        // 未指定扫描包时不做包过滤，避免 GroupedOpenApi 扫描空包
        String basePackage = swaggerProperties.getBasePackage();
        if (basePackage != null && !basePackage.trim().isEmpty())
        {
            List<String> packages = new ArrayList<>();
            for (String pkg : basePackage.split(","))
            {
                if (!pkg.trim().isEmpty())
                {
                    packages.add(pkg.trim());
                }
            }
            builder.packagesToScan(packages.toArray(new String[0]));
        }
        return builder.build();
    }
}
