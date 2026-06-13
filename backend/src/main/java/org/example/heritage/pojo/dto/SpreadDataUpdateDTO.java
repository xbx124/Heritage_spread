package org.example.heritage.pojo.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class SpreadDataUpdateDTO {

    @NotNull(message = "项目ID不能为空")
    private Integer projectId;

    @NotNull(message = "渠道ID不能为空")
    private Integer channelId;

    /**
     * 统计时间，可选；为空时默认使用当前时间。
     * 前端传参格式：yyyy-MM-dd HH:mm:ss，例如 2026-05-15 10:00:00。
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime statTime;

    /**
     * 兼容旧字段 date：如果 statTime 为空但 date 不为空，则按 date 当天 00:00:00 入库。
     * 新接口建议使用 statTime。
     */
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private LocalDate date;

    @NotNull(message = "浏览量不能为空")
    @Min(value = 0, message = "浏览量不能小于0")
    private Integer viewNum;

    @NotNull(message = "曝光量不能为空")
    @Min(value = 0, message = "曝光量不能小于0")
    private Integer exposureNum;
}
