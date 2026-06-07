package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ChannelAddDTO {

    @NotBlank(message = "渠道名称不能为空")
    @Size(max = 50, message = "渠道名称不能超过50个字符")
    private String channelName;

    @NotBlank(message = "渠道类型不能为空")
    @Size(max = 50, message = "渠道类型不能超过50个字符")
    private String channelType;
}