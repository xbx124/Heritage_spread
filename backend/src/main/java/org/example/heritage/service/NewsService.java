package org.example.heritage.service;

import org.example.heritage.pojo.dto.CommentAddDTO;
import org.example.heritage.pojo.dto.NewsAuditDTO;
import org.example.heritage.pojo.dto.NewsPageQueryDTO;
import org.example.heritage.pojo.dto.NewsPublishDTO;
import org.example.heritage.pojo.vo.CommentVO;
import org.example.heritage.pojo.vo.NewsDetailVO;
import org.example.heritage.pojo.vo.NewsPageVO;

import java.util.List;

public interface NewsService {

    List<NewsPageVO> list(NewsPageQueryDTO query);

    Long count(NewsPageQueryDTO query);

    NewsDetailVO detail(Integer newsId);

    Integer publish(NewsPublishDTO dto);

    void update(Integer newsId, NewsPublishDTO dto);

    void delete(Integer newsId);

    void audit(Integer newsId, NewsAuditDTO dto);

    List<CommentVO> listComments(Integer newsId, Integer page, Integer size);

    Long countComments(Integer newsId);

    void addComment(Integer newsId, CommentAddDTO dto);
}
