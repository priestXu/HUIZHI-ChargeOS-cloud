package com.hcp.common.mybatisplus.plugins;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.ParameterUtils;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.apache.ibatis.executor.Executor;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.RowBounds;

/**
 * 分页拦截器
 * <p>
 * 重构分页插件, 当 size 小于 0 时, 直接设置为 0, 防止错误查询全表
 * <p>
 * CHG-001 T04-2：MyBatis-Plus 3.5.9 起 PaginationInnerInterceptor 迁入
 * mybatis-plus-jsqlparser 模块，且 beforeQuery 不再声明 throws SQLException，
 * 故此处覆写方法同步去掉该异常声明。
 *
 * @author seven
 * @since 2021年10月11日
 */
public class MyPaginationInnerInterceptor extends PaginationInnerInterceptor {

	@Override
	public void beforeQuery(Executor executor, MappedStatement ms, Object parameter, RowBounds rowBounds,
			ResultHandler resultHandler, BoundSql boundSql) {
		IPage<?> page = clampSize(parameter);
		super.beforeQuery(executor, ms, page, rowBounds, resultHandler, boundSql);
	}

	/**
	 * size 小于 0 时直接设置为 0，即不查询任何数据，防止错误查询全表。
	 * 抽出为独立方法便于单测覆盖（CHG-001 T05-3）。
	 */
	static IPage<?> clampSize(Object parameter) {
		IPage<?> page = ParameterUtils.findPage(parameter).orElse(null);
		if (null != page && page.getSize() < 0) {
			page.setSize(0);
		}
		return page;
	}

}
