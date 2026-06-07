package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CategoryAddDTO {

    @NotBlank(message = "分类名称不能为空")
    @Size(max = 50, message = "分类名称不能超过50个字符")
    private String categoryName;

    @Size(max = 500, message = "分类描述不能超过500个字符")
    private String categoryDesc;
}
