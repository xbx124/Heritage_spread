package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class NewsAuditDTO {

    @NotBlank(message = "审核状态不能为空")
    @Pattern(regexp = "^(published|rejected|pending)$", message = "审核状态只能是 published、rejected、pending")
    private String status;
}
