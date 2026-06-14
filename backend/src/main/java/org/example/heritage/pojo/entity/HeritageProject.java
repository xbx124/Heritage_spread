package org.example.heritage.pojo.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("heritage_project")
public class HeritageProject {

    @TableId(value = "project_id", type = IdType.AUTO)
    private Integer projectId;

    private String projectName;

    private Integer categoryId;

    private String projectIntro;

    private String area;

    /** 1上架，0下架 */
    private Integer status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;

    private Integer createId;

    private Integer updateId;
}
