package org.example.heritage.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.heritage.pojo.dto.InheritorQueryDTO;
import org.example.heritage.pojo.entity.HeritageInheritor;
import org.example.heritage.pojo.vo.InheritorVO;
import org.example.heritage.pojo.vo.SearchVO;

import java.util.List;

@Mapper
public interface HeritageInheritorMapper extends BaseMapper<HeritageInheritor> {

    List<InheritorVO> selectInheritorList(@Param("query") InheritorQueryDTO query);

    Long countInheritorList(@Param("query") InheritorQueryDTO query);

    InheritorVO selectInheritorDetail(@Param("inheritorId") Integer inheritorId);

    List<SearchVO> searchInheritors(@Param("keyword") String keyword);
}
