package org.example.heritage.pojo.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class NewsDetailVO {

    private Integer newsId;

    private String title;

    private String content;

    private String summary;

    private Integer userId;

    private String author;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime publishTime;

    private String status;

    private Integer commentsCount;

    private List<CommentVO> comments;
}
