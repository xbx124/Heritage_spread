package org.example.heritage.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.heritage.pojo.dto.NewsPageQueryDTO;
import org.example.heritage.pojo.entity.HeritageNews;
import org.example.heritage.pojo.vo.CommentVO;
import org.example.heritage.pojo.vo.NewsDetailVO;
import org.example.heritage.pojo.vo.NewsPageVO;
import org.example.heritage.pojo.vo.SearchVO;

import java.util.List;

@Mapper
public interface HeritageNewsMapper extends BaseMapper<HeritageNews> {

    List<NewsPageVO> selectNewsPage(@Param("query") NewsPageQueryDTO query);

    Long countNewsPage(@Param("query") NewsPageQueryDTO query);

    NewsDetailVO selectNewsDetail(@Param("newsId") Integer newsId);

    Long countComments(@Param("newsId") Integer newsId);

    List<CommentVO> selectComments(@Param("newsId") Integer newsId,
                                    @Param("offset") Integer offset,
                                    @Param("size") Integer size);

    int insertComment(@Param("newsId") Integer newsId,
                      @Param("userId") Integer userId,
                      @Param("content") String content);

    List<SearchVO> searchNews(@Param("keyword") String keyword);
}
