package org.example.heritage.pojo.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class ProjectAddDTO {

    @NotBlank(message = "非遗项目名称不能为空")
    @Size(max = 100, message = "非遗项目名称不能超过100个字符")
    private String projectName;

    @NotNull(message = "分类ID不能为空")
    private Integer categoryId;

    @Size(max = 100, message = "地区不能超过100个字符")
    private String area;

    @Size(max = 2000, message = "项目介绍不能超过2000个字符")
    private String projectIntro;

    /** 新增项目时可同时提交传承人列表 */
    @Size(max = 20, message = "传承人列表最多20人")
    private List<@Valid InheritorAddDTO> inheritors;
}
