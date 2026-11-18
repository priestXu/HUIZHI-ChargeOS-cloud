package com.hcp.job.core.conf;

import ch.qos.logback.classic.Level;
import com.hcp.common.core.utils.SpringUtils;
import com.hcp.common.core.utils.StringUtils;
import org.apache.ibatis.logging.slf4j.Slf4jImpl;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.defaults.DefaultSqlSessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.lang.reflect.Field;
import java.util.List;

/**
 * @author weicj
 * @Description 用于处理sql对应的日志级别
 */
@Component
public class LogLevelChangeConfig implements ApplicationRunner {
    private static final Logger logger = LoggerFactory.getLogger(LogLevelChangeConfig.class);


    @Autowired
    private LogConfig logConfig;



    /**
     * 容器初始化完成后修改nosql配置文件配置的sql语句日志级别
     */
    @Override
    public void run(ApplicationArguments args) throws Exception {
        logger.info("Start set SQL log level!");
        List<String> sqlIds = logConfig.getList();
        if (StringUtils.isEmpty(sqlIds)) {
            logger.info("FilterSqlService sqlIds no config!");
            return;
        }
        DefaultSqlSessionFactory sqlSessionFactory = SpringUtils.getBean("sqlSessionFactory");
        Configuration configuration = sqlSessionFactory.getConfiguration();
        for (String sqlIdConfig : sqlIds) {
            if (StringUtils.isEmpty(sqlIdConfig)) {
                logger.info("FilterSqlService sqlIds item config err!");
                continue;
            }
            String [] arr = sqlIdConfig.split("-");
            if (arr.length != 2) {
                logger.info("FilterSqlService sqlIds item config err!");
                continue;
            }
            String sqlId = arr[0];
            String logLevel = arr[1];
            if(logger.isInfoEnabled()){
                logger.info("Will set SQL:[{}] LOGLEVEL to [{}]", sqlId, logLevel);
            }
            changeStatementLogLevel(configuration, sqlId, logLevel);
        }
    }

    /**
     * 通过SQlMappedStatement全名查找并修改其对应的日志对象级别为关闭
     */
    public void changeStatementLogLevel(Configuration configuration, String name,String logLevel) {
        MappedStatement mappedStatement = null;
        try {
            mappedStatement = configuration.getMappedStatement(name);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if(mappedStatement == null){
            logger.warn("SQL:--->[{}] is not exist!",name);
            return;
        }
        Slf4jImpl slf4jLog = (Slf4jImpl) mappedStatement.getStatementLog();
        // CHG-001 T04-7：原实现反射 logback 私有字段 effectiveLevelInt，在 Spring Boot 3
        // (slf4j 2 + logback 1.4) 下字段链已变，必然失败且被静默吞掉。
        // 改为取 mybatis 持有的 slf4j Logger，若为 logback 实现则走公有 setLevel。
        try {
            Field logField = slf4jLog.getClass().getDeclaredField("log");
            logField.setAccessible(true);
            Object logObj = logField.get(slf4jLog);
            if (logObj instanceof ch.qos.logback.classic.Logger) {
                ((ch.qos.logback.classic.Logger) logObj).setLevel(toLevel(logLevel));
                LogLevelChangeConfig.logger.info("SQL[{}] 日志级别已设置为 {}", name, logLevel);
            } else {
                LogLevelChangeConfig.logger.warn(
                        "SQL[{}] 日志级别未设置：当前 slf4j 实现不是 logback（实际 {}），该功能不可用，"
                                + "SQL 日志保持默认级别", name,
                        logObj == null ? "null" : logObj.getClass().getName());
            }
        } catch (NoSuchFieldException | IllegalAccessException | RuntimeException e) {
            LogLevelChangeConfig.logger.warn(
                    "SQL[{}] 日志级别未设置，该功能不可用，SQL 日志保持默认级别。原因：{}: {}",
                    name, e.getClass().getSimpleName(), e.getMessage());
        }
    }

    /**
     * 把配置里的级别字符串转成 logback Level。
     * 未知取值回退 TRACE，与原有 getLevelInt 的默认值(10000)保持一致。
     */
    private Level toLevel(String logLevel) {
        if (logLevel == null) {
            return Level.TRACE;
        }
        switch (logLevel.toLowerCase()) {
            case "off":
                return Level.OFF;
            case "error":
                return Level.ERROR;
            case "warn":
                return Level.WARN;
            case "debug":
                return Level.DEBUG;
            case "info":
                return Level.INFO;
            case "trace":
            default:
                return Level.TRACE;
        }
    }




}

