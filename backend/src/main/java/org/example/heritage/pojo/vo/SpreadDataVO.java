package org.example.heritage.pojo.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class SpreadDataVO {

    private Integer dataId;

    private Integer projectId;

    private String projectName;

    private Integer channelId;

    private String channelName;

    private Integer viewNum;

    private Integer exposureNum;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime statTime;
}