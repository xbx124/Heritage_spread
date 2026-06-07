package org.example.heritage.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.heritage.pojo.entity.SpreadChannel;
import org.example.heritage.pojo.vo.ChannelStatsVO;
import org.example.heritage.pojo.vo.ChannelVO;

import java.util.List;

@Mapper
public interface SpreadChannelMapper extends BaseMapper<SpreadChannel> {

    List<ChannelVO> selectChannelList(@Param("includeDisabled") boolean includeDisabled);

    List<ChannelStatsVO> selectChannelStats();
}
