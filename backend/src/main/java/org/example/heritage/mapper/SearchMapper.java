package org.example.heritage.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.heritage.pojo.vo.SearchVO;

import java.util.List;

@Mapper
public interface SearchMapper {

    List<SearchVO> searchAll(@Param("keyword") String keyword);
}
