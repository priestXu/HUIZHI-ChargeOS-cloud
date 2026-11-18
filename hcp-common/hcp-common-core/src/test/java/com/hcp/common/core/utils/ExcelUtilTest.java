package com.hcp.common.core.utils;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.io.ByteArrayOutputStream;
import java.util.Collections;
import java.util.List;

import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletResponse;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.hcp.common.core.annotation.Excel;
import com.hcp.common.core.utils.poi.ExcelUtil;

/**
 * ExcelUtil 导出回归测试（CHG-001 T05-3 / D8）
 *
 * 覆盖 jakarta.servlet 迁移后的导出链路：POI 生成 xlsx（首两字节为 PK）并写入响应流。
 */
class ExcelUtilTest
{
    /** 测试用导出模型 */
    public static class DemoRow
    {
        @Excel(name = "名称")
        private String name;

        @Excel(name = "数量")
        private Integer count;

        public DemoRow(String name, Integer count)
        {
            this.name = name;
            this.count = count;
        }

        public String getName()
        {
            return name;
        }

        public Integer getCount()
        {
            return count;
        }
    }

    /** 内存响应流，避免依赖容器 */
    private static class MemoryOutputStream extends ServletOutputStream
    {
        private final ByteArrayOutputStream buffer = new ByteArrayOutputStream();

        @Override
        public void write(int b)
        {
            buffer.write(b);
        }

        @Override
        public boolean isReady()
        {
            return true;
        }

        @Override
        public void setWriteListener(WriteListener listener)
        {
            // no-op
        }

        byte[] toByteArray()
        {
            return buffer.toByteArray();
        }
    }

    @Test
    @DisplayName("导出 xlsx：写入 PK 开头的合法 xlsx 字节流")
    void exportExcelWritesXlsxStream() throws Exception
    {
        HttpServletResponse response = mock(HttpServletResponse.class);
        MemoryOutputStream out = new MemoryOutputStream();
        when(response.getOutputStream()).thenReturn(out);

        List<DemoRow> rows = Collections.singletonList(new DemoRow("测试桩", 3));
        ExcelUtil<DemoRow> util = new ExcelUtil<>(DemoRow.class);
        util.exportExcel(response, rows, "充电桩");

        verify(response, atLeastOnce()).setContentType(anyString());
        byte[] bytes = out.toByteArray();
        assertTrue(bytes.length > 0, "导出内容不能为空");
        // xlsx 是 zip 容器，魔数为 0x50 0x4B
        assertTrue(bytes.length > 1 && bytes[0] == 'P' && bytes[1] == 'K',
                "导出内容应为 xlsx(zip) 格式");
    }
}
