package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class SpreadDataUpdateDTO {

    @NotNull(message = "项目ID不能为空")
    private Integer projectId;

    @NotNull(message = "渠道ID不能为空")
    private Integer channelId;

    @NotNull(message = "统计日期不能为空")
    private LocalDate date;

    @NotNull(message = "浏览量不能为空")
    @Min(value = 0, message = "浏览量不能小于0")
    private Integer viewNum;

    @NotNull(message = "曝光量不能为空")
    @Min(value = 0, message = "曝光量不能小于0")
    private Integer exposureNum;
}
