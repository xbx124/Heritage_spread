package org.example.heritage.pojo.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class ProjectDetailVO {

    private Integer projectId;

    private String projectName;

    private Integer categoryId;

    private String categoryName;

    private String area;

    private String projectIntro;

    private Integer status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;

    private List<InheritorVO> inheritors;
}
