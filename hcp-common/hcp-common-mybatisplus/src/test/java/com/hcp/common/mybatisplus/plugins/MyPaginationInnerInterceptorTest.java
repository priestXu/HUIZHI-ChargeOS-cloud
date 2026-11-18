package com.hcp.common.mybatisplus.plugins;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

/**
 * 分页拦截器回归测试（CHG-001 T05-3 / D8）
 *
 * 锁定「size < 0 即不查询任何数据」的既有行为，防止升级 MyBatis-Plus 后回退成全表查询。
 */
class MyPaginationInnerInterceptorTest
{
    @Test
    @DisplayName("size 为负数时被钳制为 0")
    void negativeSizeIsClampedToZero()
    {
        Page<String> page = new Page<>(1, -1);
        assertEquals(-1, page.getSize());

        Object result = MyPaginationInnerInterceptor.clampSize(page);

        assertEquals(page, result);
        assertEquals(0, page.getSize());
    }

    @Test
    @DisplayName("size 为正常值时不改动")
    void positiveSizeIsUntouched()
    {
        Page<String> page = new Page<>(2, 20);
        MyPaginationInnerInterceptor.clampSize(page);
        assertEquals(20, page.getSize());
        assertEquals(2, page.getCurrent());
    }

    @Test
    @DisplayName("参数中不含分页对象时返回 null，交由父类处理")
    void nonPageParameterReturnsNull()
    {
        assertNull(MyPaginationInnerInterceptor.clampSize("not-a-page"));
    }
}
