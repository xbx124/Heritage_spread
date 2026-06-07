package org.example.heritage.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.heritage.pojo.dto.SpreadDataUpdateDTO;
import org.example.heritage.pojo.entity.SpreadData;
import org.example.heritage.pojo.vo.SpreadDataVO;
import org.example.heritage.pojo.vo.TrendDataVO;

import java.util.List;

@Mapper
public interface SpreadDataMapper extends BaseMapper<SpreadData> {

    List<SpreadDataVO> selectSpreadDataList();

    List<TrendDataVO> selectProjectTrend(@Param("projectId") Integer projectId);
}
