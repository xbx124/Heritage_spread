package org.example.heritage.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CommentAddDTO {

    @NotBlank(message = "评论内容不能为空")
    @Size(max = 200)
    private String content;
}
