package org.example.heritage.pojo.vo;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class ChannelStatsVO {

    private Integer channelId;

    private String channelName;

    private String channelType;

    private Long totalView;

    private Long totalExposure;
}
