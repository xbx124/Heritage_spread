package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ProjectPageQueryDTO {

    private Integer categoryId;

    /** 地区筛选 */
    private String area;

    /** 项目名称关键词 */
    private String keyword;

    @Min(value = 1, message = "页码最小为1")
    @NotNull
    private Integer page = 1;

    @Min(value = 1, message = "每页条数最小为1")
    @Max(value = 50, message = "每页条数最大为50")
    @NotNull
    private Integer size = 10;

    public Integer getOffset() {
        return (page - 1) * size;
    }
}
