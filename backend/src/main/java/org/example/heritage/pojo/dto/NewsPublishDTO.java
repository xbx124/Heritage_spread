package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class NewsPublishDTO {

    @NotBlank(message = "资讯标题不能为空")
    @Size(max = 100, message = "资讯标题不能超过100个字符")
    private String title;

    @NotBlank(message = "资讯内容不能为空")
    @Size(max = 10000, message = "资讯内容不能超过10000个字符")
    private String content;

    /** 资讯摘要 */
    @Size(max = 300, message = "资讯摘要不能超过300个字符")
    private String summary;

    /** published / draft / pending */
    @Pattern(regexp = "^(published|draft|pending)$", message = "资讯状态只能是 published、draft、pending")
    private String status = "pending";
}
