package org.example.heritage.pojo.vo;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class ProjectStatsVO {

    private Integer projectId;

    private String projectName;

    private Long totalView;

    private Long totalExposure;

    private Integer channelCount;
}
