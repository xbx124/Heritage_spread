package org.example.heritage.pojo.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("heritage_inheritor")
public class HeritageInheritor {

    @TableId(value = "inheritor_id", type = IdType.AUTO)
    private Integer inheritorId;

    private String name;

    private Integer projectId;

    private Integer years;

    private String intro;

    /** 头像地址 */
    private String avatar;

    /** 1正常，0删除 */
    private Integer status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;

    private Integer createId;

    private Integer updateId;
}
