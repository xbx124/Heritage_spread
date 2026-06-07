package org.example.heritage.service;

import org.example.heritage.pojo.dto.SpreadDataUpdateDTO;
import org.example.heritage.pojo.vo.ChannelStatsVO;
import org.example.heritage.pojo.vo.ProjectStatsVO;
import org.example.heritage.pojo.vo.SpreadDataVO;
import org.example.heritage.pojo.vo.TrendDataVO;

import java.util.List;

public interface StatsService {

    List<ChannelStatsVO> channelStats();

    List<SpreadDataVO> projectStatsList();

    ProjectStatsVO projectStats(Integer projectId);

    List<TrendDataVO> trend(Integer projectId);

    void record(SpreadDataUpdateDTO dto);
}