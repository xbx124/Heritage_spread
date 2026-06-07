package org.example.heritage.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.HeritageProjectMapper;
import org.example.heritage.mapper.SpreadChannelMapper;
import org.example.heritage.mapper.SpreadDataMapper;
import org.example.heritage.pojo.dto.SpreadDataUpdateDTO;
import org.example.heritage.pojo.entity.HeritageProject;
import org.example.heritage.pojo.entity.SpreadChannel;
import org.example.heritage.pojo.entity.SpreadData;
import org.example.heritage.pojo.vo.ChannelStatsVO;
import org.example.heritage.pojo.vo.ProjectStatsVO;
import org.example.heritage.pojo.vo.SpreadDataVO;
import org.example.heritage.pojo.vo.TrendDataVO;
import org.example.heritage.service.StatsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class StatsServiceImpl implements StatsService {

    @Autowired
    private SpreadChannelMapper channelMapper;

    @Autowired
    private HeritageProjectMapper projectMapper;

    @Autowired
    private SpreadDataMapper spreadDataMapper;

    @Override
    public List<ChannelStatsVO> channelStats() {
        return channelMapper.selectChannelStats();
    }

    @Override
    public List<SpreadDataVO> projectStatsList() {
        return spreadDataMapper.selectSpreadDataList();
    }

    @Override
    public ProjectStatsVO projectStats(Integer projectId) {
        HeritageProject project = projectMapper.selectById(projectId);
        if (project == null || project.getStatus() == null || project.getStatus() != 1) {
            throw new BusinessException(404, "项目不存在或已下架");
        }
        ProjectStatsVO vo = projectMapper.selectProjectStats(projectId);
        if (vo == null) {
            throw new BusinessException(404, "项目不存在或暂无统计数据");
        }
        return vo;
    }

    @Override
    public List<TrendDataVO> trend(Integer projectId) {
        HeritageProject project = projectMapper.selectById(projectId);
        if (project == null || project.getStatus() == null || project.getStatus() != 1) {
            throw new BusinessException(404, "项目不存在或已下架");
        }
        return spreadDataMapper.selectProjectTrend(projectId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void record(SpreadDataUpdateDTO dto) {
        checkAdmin();

        HeritageProject project = projectMapper.selectById(dto.getProjectId());
        if (project == null || project.getStatus() == null || project.getStatus() != 1) {
            throw new BusinessException(404, "项目不存在或已下架");
        }

        SpreadChannel channel = channelMapper.selectById(dto.getChannelId());
        if (channel == null) {
            throw new BusinessException(404, "渠道不存在");
        }
        if (channel.getStatus() != null && channel.getStatus() == 0) {
            throw new BusinessException(400, "渠道已禁用，无法更新传播数据");
        }

        LocalDateTime startTime = dto.getDate().atStartOfDay();
        LocalDateTime endTime = dto.getDate().plusDays(1).atStartOfDay();

        SpreadData old = spreadDataMapper.selectOne(
                new LambdaQueryWrapper<SpreadData>()
                        .eq(SpreadData::getProjectId, dto.getProjectId())
                        .eq(SpreadData::getChannelId, dto.getChannelId())
                        .ge(SpreadData::getStatTime, startTime)
                        .lt(SpreadData::getStatTime, endTime)
                        .orderByDesc(SpreadData::getUpdateTime)
                        .orderByDesc(SpreadData::getCreateTime)
                        .orderByDesc(SpreadData::getDataId)
                        .last("LIMIT 1")
        );

        LocalDateTime now = LocalDateTime.now();
        Integer currentUserId = getCurrentUserId();

        if (old == null) {
            SpreadData spreadData = new SpreadData();
            spreadData.setProjectId(dto.getProjectId());
            spreadData.setChannelId(dto.getChannelId());
            spreadData.setViewNum(dto.getViewNum());
            spreadData.setExposureNum(dto.getExposureNum());

            spreadData.setStatTime(startTime);
            spreadData.setCreateTime(now);
            spreadData.setUpdateTime(now);
            spreadData.setCreateId(currentUserId);
            spreadData.setUpdateId(currentUserId);

            spreadDataMapper.insert(spreadData);
        } else {
            old.setViewNum(dto.getViewNum());
            old.setExposureNum(dto.getExposureNum());

            old.setStatTime(startTime);
            old.setUpdateTime(now);
            old.setUpdateId(currentUserId);

            spreadDataMapper.updateById(old);
        }
    }

    private Integer getCurrentUserId() {
        Long userId = UserContext.getCurrentUserId();
        return userId == null ? null : userId.intValue();
    }

    private void checkAdmin() {
        if (!RoleConstants.ADMIN.equals(UserContext.getCurrentRole())) {
            throw new BusinessException(403, "权限不足");
        }
    }
}