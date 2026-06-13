package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class InheritorAddDTO {

    @NotBlank(message = "传承人姓名不能为空")
    @Size(max = 30, message = "传承人姓名不能超过30个字符")
    private String name;

    @NotNull(message = "项目ID不能为空")
    private Integer projectId;

    @Min(value = 0, message = "从业年限不能为负数")
    private Integer years = 0;

    @Size(max = 2000, message = "传承人介绍不能超过2000个字符")
    private String intro;

}
